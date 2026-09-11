# أكاديمية التميز — Technical Reference

> **Platform**: Multi-Tenant Educational SaaS · Flutter (Mobile) · Flutter Web (Admin) · Firebase Backend
> **Last Updated**: 2026-09-08 · **Status**: Active Development

---

## Table of Contents

1. [System Architecture & Tenancy Model](#1-system-architecture--tenancy-model)
2. [Database Schemas & Models](#2-database-schemas--models)
3. [Security Rules & RBAC](#3-security-rules--rbac)
4. [Core Transactional & Locking Logic](#4-core-transactional--locking-logic)
5. [State Management Architecture](#5-state-management-architecture)
6. [UI/UX Matrix & Data Mapping](#6-uiux-matrix--data-mapping)
7. [Web Admin Dashboard Specs](#7-web-admin-dashboard-specs)
8. [API Contract Reference](#8-api-contract-reference)

---

## 1. System Architecture & Tenancy Model

### 1.1 Tenancy Design

```
Tenant = Teacher Account (teacherId = Firebase Auth UID)

/teachers/{teacherId}/
  ├── users/          ← students enrolled under this teacher
  ├── codes/          ← scratch codes issued by this teacher
  └── units/          ← curriculum units published by this teacher
        └── items/    ← individual lessons per unit
```

**Isolation guarantee**: Every Firestore read/write includes the `teacherId` path segment. Cross-tenant reads are structurally impossible and enforced at the security rules layer.

### 1.2 Tech Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Mobile Client | Flutter | SDK ^3.10.4 | Arabic RTL, `Locale('ar')` hardcoded |
| Web Admin | Flutter Web | SDK ^3.10.4 | Separate entrypoint (`web/`) |
| Auth | Firebase Auth | `firebase_auth ^6.x` | Google Sign-In (students), Email/Password (teachers) |
| Database | Cloud Firestore | `cloud_firestore ^6.x` | Multi-tenant path hierarchy |
| Storage | Firebase Storage | — | PDF & video asset hosting |
| State (Mobile) | flutter_bloc | `^9.1.1` | Cubits + BLoC pattern |
| Routing | GoRouter | `^17.x` | Auth-aware redirect guard |
| Video Playback | youtube_player_flutter | `^10.0.1` | Inline player, no Scaffold wrapper |

### 1.3 Deployment Topology

```
┌─────────────────────────────────────────────────────┐
│                  Firebase Project                    │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Auth    │  │  Firestore   │  │    Storage    │  │
│  │ (shared) │  │ (multi-path) │  │  (per-tenant) │  │
│  └────┬─────┘  └──────┬───────┘  └───────┬───────┘  │
│       │               │                  │           │
└───────┼───────────────┼──────────────────┼───────────┘
        │               │                  │
   ┌────▼────┐    ┌──────▼──────┐   ┌──────▼──────┐
   │ Student │    │   Admin     │   │   Admin     │
   │ Flutter │    │  Flutter    │   │  File Mgmt  │
   │  (APK)  │    │  Web Panel  │   │  (Upload)   │
   └─────────┘    └─────────────┘   └─────────────┘
```

### 1.4 Role Taxonomy

```typescript
type Role = "student" | "teacher" | "admin";

// Stored in Firestore at the user document level.
// "admin" = platform super-admin (cross-tenant access).
// "teacher" = tenant owner; reads/writes own subtree only.
// "student" = enrolled in one teacher's tenant.
```

---

## 2. Database Schemas & Models

### 2.1 Teacher Document

**Path**: `/teachers/{teacherId}`

```typescript
interface TeacherDocument {
  uid: string;                    // = Firebase Auth UID
  display_name: string;
  email: string;
  role: "teacher";
  subject: string;                // e.g. "تاريخ وجغرافيا"
  created_at: Timestamp;
  is_active: boolean;             // platform-level disable flag
}
```

**Indexes**: None required (top-level, queried by doc ID only).

---

### 2.2 User (Student) Document

**Path**: `/teachers/{teacherId}/users/{userId}`

```typescript
interface UserDocument {
  // ── Identity ────────────────────────────────────────
  uid: string;                    // = Firebase Auth UID; also the doc ID
  email: string | null;
  full_name: string;
  student_phone: string;          // 10+ digits, digits only
  parent_phone: string;           // 10+ digits, digits only

  // ── Academic ────────────────────────────────────────
  academic_grade: AcademicGrade;  // canonical key (see §2.5)
  is_profile_complete: boolean;

  // ── Subscription ────────────────────────────────────
  subscription_active: boolean;   // denormalised flag; source of truth = end_date
  subscription_start_date: Timestamp | null;
  subscription_end_date: Timestamp | null;  // Gate condition: > now()

  // ── Audit ───────────────────────────────────────────
  created_at: Timestamp;
  teacher_id: string;             // redundant ref for cross-collection queries
}
```

**Active subscription predicate** (evaluated client-side):
```dart
bool get hasActiveSubscription =>
    subscriptionEndDate != null &&
    subscriptionEndDate!.isAfter(DateTime.now());
```

**Indexes**:

| Collection | Fields | Query Use |
|---|---|---|
| `users` | `academic_grade ASC` | Grade-based content filtering |
| `users` | `subscription_end_date ASC` | Expiry batch jobs |

---

### 2.3 Code (Scratch Card) Document

**Path**: `/teachers/{teacherId}/codes/{codeId}`

```typescript
interface CodeDocument {
  code: string;                   // = doc ID; uppercase alphanumeric, e.g. "ABCD-1234-EFGH"
  duration_days: number;          // default 30; added to max(now, current_expiry)
  is_redeemed: boolean;           // default false
  redeemed_by: string | null;     // userId; null until redeemed
  redeemed_at: Timestamp | null;  // server timestamp set during transaction
  created_at: Timestamp;
  created_by: string;             // teacherId
  batch_id: string | null;        // links to batch generation run (optional)
}
```

**Indexes**:

| Fields | Query Use |
|---|---|
| `is_redeemed ASC, created_at DESC` | Admin dashboard: unused code listing |
| `batch_id ASC` | Batch export |

---

### 2.4 Curriculum Unit Document

**Path**: `/teachers/{teacherId}/units/{unitId}`

```typescript
interface UnitDocument {
  unit_id: string;                // = doc ID (auto-generated)
  title: string;
  description: string | null;
  academic_grade: AcademicGrade;  // filter key — only shown to matching grade
  is_published: boolean;          // false = draft; invisible to students
  order_index: number;            // integer; drag-and-drop reorder target
  thumbnail_url: string | null;   // Firebase Storage URL
  created_at: Timestamp;
  updated_at: Timestamp;
}
```

**Indexes**:

| Fields | Query Use |
|---|---|
| `academic_grade ASC, is_published ASC, order_index ASC` | Student home screen |
| `is_published ASC, updated_at DESC` | Admin draft/published listing |

---

### 2.5 Unit Item Document

**Path**: `/teachers/{teacherId}/units/{unitId}/items/{itemId}`

```typescript
type ItemType = "VIDEO" | "PDF";

interface UnitItemDocument {
  item_id: string;                // = doc ID
  title: string;
  type: ItemType;
  url: string;                    // YouTube watch URL (VIDEO) | Storage URL (PDF)
  duration: number | null;        // seconds; VIDEO only
  order_index: number;            // drag-and-drop reorder target
  is_published: boolean;
  created_at: Timestamp;
}

// Derived fields (client-computed, never stored):
// videoId: string  ← Uri.parse(url).queryParameters['v']
// formattedDuration: string  ← "mm:ss" or "h:mm:ss"
```

---

### 2.6 Academic Grade Canonical Keys

```typescript
type AcademicGrade =
  | "1st_prep"        // الصف الأول الإعدادي
  | "2nd_prep"        // الصف الثاني الإعدادي
  | "3rd_prep"        // الصف الثالث الإعدادي
  | "1st_secondary"   // الصف الأول الثانوي
  | "2nd_secondary"   // الصف الثاني الثانوي
  | "3rd_secondary";  // الصف الثالث الثانوي

// JSON → Canonical normalisation map (handles legacy/typo keys in JSON data):
const GRADE_NORMALISATION: Record<string, AcademicGrade> = {
  "1st_sec":  "1st_secondary",
  "2nd_sec":  "2nd_secondary",
  "3rd_sec":  "3rd_secondary",
  "2st_sec":  "2nd_secondary",   // ← source data typo fix
};
// Keys not in the map pass through unchanged (prep grades are already canonical).
```

---

## 3. Security Rules & RBAC

### 3.1 Firestore Rules Pseudocode

```javascript
// /teachers/{teacherId}
match /teachers/{teacherId} {
  allow read: if isTeacher(teacherId) || isAdmin();
  allow write: if isTeacher(teacherId) || isAdmin();

  // /teachers/{teacherId}/users/{userId}
  match /users/{userId} {
    allow read:   if isOwnerStudent(teacherId, userId) || isTeacher(teacherId);
    allow create: if isAuthenticated();       // profile completion after Google Sign-In
    allow update: if isOwnerStudent(teacherId, userId)
                  || isTeacher(teacherId);   // teacher can edit grade/subscription
    allow delete: if isTeacher(teacherId) || isAdmin();
  }

  // /teachers/{teacherId}/codes/{codeId}
  match /codes/{codeId} {
    allow read:   if isTeacher(teacherId);                    // admin view
    allow create: if isTeacher(teacherId);
    allow update: if isAuthenticated()                        // student redeems
                  && request.resource.data.is_redeemed == true
                  && request.resource.data.redeemed_by == request.auth.uid;
    allow delete: if isTeacher(teacherId);
  }

  // /teachers/{teacherId}/units/{unitId}
  match /units/{unitId} {
    allow read:   if isTeacher(teacherId)
                  || (isEnrolledStudent(teacherId)
                      && resource.data.is_published == true);
    allow write:  if isTeacher(teacherId);

    match /items/{itemId} {
      allow read:  if isTeacher(teacherId)
                   || (isEnrolledStudent(teacherId)
                       && get(/teachers/$(teacherId)/units/$(unitId)).data.is_published == true
                       && resource.data.is_published == true);
      allow write: if isTeacher(teacherId);
    }
  }
}

// Helper functions
function isAuthenticated() { return request.auth != null; }
function isAdmin()         { return isAuthenticated() && request.auth.token.role == "admin"; }
function isTeacher(tid)    { return isAuthenticated() && request.auth.uid == tid; }
function isOwnerStudent(tid, uid) {
  return isAuthenticated()
      && request.auth.uid == uid
      && exists(/teachers/$(tid)/users/$(uid));
}
function isEnrolledStudent(tid) {
  return isAuthenticated()
      && exists(/teachers/$(tid)/users/$(request.auth.uid));
}
```

### 3.2 RBAC Matrix

| Operation | Student | Teacher (own tenant) | Admin |
|---|:---:|:---:|:---:|
| Read own user doc | ✅ | ✅ | ✅ |
| Update own subscription | ✅ (via txn) | ✅ | ✅ |
| Read other students | ❌ | ✅ | ✅ |
| Create/delete codes | ❌ | ✅ | ✅ |
| Redeem code | ✅ | ❌ | ❌ |
| Create/edit units | ❌ | ✅ | ✅ |
| Read published units | ✅ (gated) | ✅ | ✅ |
| Read draft units | ❌ | ✅ | ✅ |
| Cross-tenant read | ❌ | ❌ | ✅ |

---

## 4. Core Transactional & Locking Logic

### 4.1 Code Redemption Transaction

**Path**: `FirestoreService.redeemCode(uid, code, teacherId)`

```
PRECONDITIONS (inside runTransaction):
  codeSnap = txn.get(/teachers/{teacherId}/codes/{CODE})
  userSnap = txn.get(/teachers/{teacherId}/users/{uid})

VALIDATION:
  if (!codeSnap.exists)           → throw RedemptionException(invalidCode)
  if (codeSnap.is_redeemed)       → throw RedemptionException(alreadyRedeemed)

EXPIRY CALCULATION:
  durationDays  = codeSnap.duration_days  // default 30
  currentExpiry = userSnap.subscription_end_date?.toDate() ?? null
  baseDate      = (currentExpiry != null && currentExpiry > now())
                    ? currentExpiry          // extend active subscription
                    : now()                  // start fresh
  newExpiry     = baseDate + Duration(days: durationDays)

WRITES (atomic):
  txn.update(codeRef, {
    is_redeemed: true,
    redeemed_by: uid,
    redeemed_at: FieldValue.serverTimestamp(),
  })

  txn.set(userRef, {
    subscription_active:     true,
    subscription_start_date: FieldValue.serverTimestamp(),
    subscription_end_date:   Timestamp.fromDate(newExpiry),
  }, merge: true)

RETURN: UserEntity with updated subscription fields
```

**Expiry formula**:
```
newExpiry = max(DateTime.now(), subscription_end_date ?? DateTime.now())
            + Duration(days: duration_days)
```

**Exception taxonomy**:

```dart
enum RedemptionFailure { invalidCode, alreadyRedeemed, transactionFailed }

class RedemptionException implements Exception {
  const RedemptionException(this.failure);
  final RedemptionFailure failure;
}
```

### 4.2 Content Gate — 3-Tier Access Filter

All three conditions must be `true` for a student to view item content:

| Tier | Condition | Enforcement Layer |
|---|---|---|
| **Tenant** | Student document exists at `/teachers/{teacherId}/users/{uid}` | Firestore rules + `isEnrolledStudent()` |
| **Grade** | `unit.academic_grade == user.academic_grade` | Client-side Cubit filter; mirrored in Firestore query `where` clause |
| **Subscription** | `user.subscription_end_date > DateTime.now()` | `UserEntity.hasActiveSubscription`; evaluated in `SubscriptionCubit` |

```
ACCESS = Tenant ∧ Grade ∧ Subscription

Tier 1 fail → 403 / redirect to login
Tier 2 fail → unit not shown in list
Tier 3 fail → unit shown, locked (lock icon + redeem sheet trigger)
```

### 4.3 Subscription State Machine

```
                   ┌──────────────────┐
             ┌────►│  SubscriptionInitial │
             │     └────────┬─────────┘
             │              │ checkSubscriptionStatus(user)
             │              ▼
             │     ┌──────────────────┐
             │     │SubscriptionActive│◄──────┐
             │     │  (expiryDate)    │       │
             │     └──────┬───────────┘       │
             │            │ expiry > now?      │ redeemCode() success
             │            │ No                │
             │            ▼                   │
             │     ┌──────────────────┐       │
             │     │SubscriptionExpired│      │
             │     └──────┬───────────┘       │
             │            │ redeemCode()       │
             │            ▼                   │
             │     ┌──────────────────┐       │
             │     │SubscriptionLoading│      │
             │     └──────┬───────────┘       │
             │            ├──── success ───────┘
             │            │
             │            └──── failure ──► SubscriptionFailure(message)
             │                                      │
             └──────────────────────────────────────┘
                           reset()
```

---

## 5. State Management Architecture

### 5.1 BLoC / Cubit Inventory

| Class | Type | Scope | Responsibility |
|---|---|---|---|
| `AuthBloc` | BLoC | Global | Google Sign-In, session check, profile gate |
| `SubscriptionCubit` | Cubit | Global | Subscription status, code redemption |
| `SettingsCubit` | Cubit | Global | Theme, locale preferences |
| `PlaylistsCubit` | Cubit | Route (`/dashboard`) | Grade-filtered content list |
| `UnitsCubit` | Cubit | Route (`/dashboard`) | Firestore-backed unit listing (future) |

### 5.2 AuthBloc Event → State Map

```
CheckAuthStatusRequested  →  AuthLoading → {Unauthenticated | ProfileIncomplete | Authenticated}
GoogleSignInRequested     →  AuthLoading → {ProfileIncomplete | Authenticated | AuthFailure}
CompleteProfileSubmitted  →  AuthLoading → {Authenticated | AuthFailure}
SignOutRequested          →              →  Unauthenticated
```

### 5.3 GoRouter Redirect Table

| AuthBloc State | On `/login` | On `/complete-profile` | On protected route |
|---|---|---|---|
| `AuthInitial` / `AuthLoading` | stay | stay | stay |
| `Unauthenticated` / `AuthFailure` | stay | → `/login` | → `/login` |
| `ProfileIncomplete` | → `/complete-profile` | stay | → `/complete-profile` |
| `Authenticated` | → `/dashboard` | → `/dashboard` | stay |

### 5.4 Route Inventory

| Path | Screen | BLoC Deps | Notes |
|---|---|---|---|
| `/login` | `LoginScreen` | `AuthBloc` | Google Sign-In button only |
| `/complete-profile` | `CompleteProfileScreen` | `AuthBloc` | Form: name, phones, grade |
| `/dashboard` | `DashboardScreen` | `AuthBloc`, `PlaylistsCubit`, `SubscriptionCubit` | Grade-filtered + locked content |
| `/playlist-detail` | `PlaylistDetailScreen` | — | `extra: PlaylistModel` via GoRouter |
| `/settings` | `SettingsScreen` | `AuthBloc`, `SettingsCubit`, `SubscriptionCubit` | Sign-out resets subscription |
| `/lesson` | `LessonScreen` | — | YouTube inline player |
| `/learning-path` | `LearningPathScreen` | — | Static |
| `/quiz` | `QuizScreen` | — | Static |

---

## 6. UI/UX Matrix & Data Mapping

### 6.1 Onboarding Flow

```
Google Sign-In
    │
    ▼
Firestore /users/{uid} exists AND is_profile_complete == true?
    ├── YES → emit Authenticated → /dashboard
    └── NO  → emit ProfileIncomplete → /complete-profile
                  │
                  ▼
            Form: full_name | student_phone | parent_phone | academic_grade
                  │
                  ▼
            saveUserProfile() → is_profile_complete: true
                  │
                  ▼
            emit Authenticated → /dashboard
```

**`/complete-profile` Field Spec**:

| Field | Input Type | Validation | Firestore Key |
|---|---|---|---|
| `full_name` | Text | required, non-empty | `full_name` |
| `student_phone` | Numeric | ≥10 digits | `student_phone` |
| `parent_phone` | Numeric | ≥10 digits | `parent_phone` |
| `academic_grade` | Dropdown | one of `AcademicGrade` enum | `academic_grade` |

### 6.2 Dashboard Screen Layout

```
┌─────────────────────────────────────┐
│  Header: Hi {full_name}  [Grade]    │  ← user.fullName, gradeDisplayName()
│  [Avatar initials]                  │
├─────────────────────────────────────┤
│  [Subscription Banner]              │  ← SubscriptionCubit state
│  Green: "اشتراكك نشط 🎉 — N أيام"  │
│  Orange: "انتهى اشتراكك → tap"      │
├─────────────────────────────────────┤
│  [Progress Circle] 0%               │  ← placeholder; future: watch history
├─────────────────────────────────────┤
│  ── قوائم التشغيل ──                │
│  ┌─────────────────────────────┐    │
│  │ [Thumbnail / Lock overlay]  │    │  isLocked → grayscale + padlock icon
│  │ Playlist Title              │    │
│  │ 🔒 فعّل كوداً  [تفعيل الكود]│    │  isLocked
│  │ ▶ N فيديو    [مشاهدة]      │    │  isUnlocked
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Content Lock Decision**:

```dart
final isLocked = context.read<SubscriptionCubit>().state is! SubscriptionActive;
```

**Tap routing**:

```dart
onTap: isLocked
  ? () => showRedeemCodeSheet(context)   // bottom sheet
  : () => context.push('/playlist-detail', extra: playlist);
```

### 6.3 Redeem Code Bottom Sheet Spec

| Element | Value |
|---|---|
| Title | `redeemCodeTitle` = "تفعيل كود الاشتراك" |
| Subtitle | `redeemCodeSubtitle` = "أدخل كود الخدش للوصول إلى المحتوى" |
| Input hint | `"XXXX-XXXX-XXXX"` |
| Input formatter | `UpperCaseTextFormatter` + `FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-]'))` |
| Submit label | `redeemButton` = "تفعيل الكود" |
| Loading state | `CircularProgressIndicator` replaces button label |
| Success | Sheet closes; green SnackBar; cards unlock immediately |
| Failure | Sheet stays open; red SnackBar; cubit reset to `SubscriptionExpired` |

### 6.4 Playlist Detail Screen Layout

```
┌─────────────────────────────────────┐
│  [YoutubePlayer 220px height]        │  ← YoutubePlayerController.fromVideoId()
├─────────────────────────────────────┤
│  ← {playlist_title}                 │  ← back button + title
│  {currently_playing_video.title}    │  ← max 2 lines
│  ▶ N فيديو  ·  mm:ss               │
├─────────────────────────────────────┤
│  ─────────────────────────────────  │
│  [Thumbnail 100×60]  Title           │  ← _VideoTile
│                      ⏱ mm:ss         │
│                      [يُشغَّل الآن]   │  ← only on selected
│  [Thumbnail 100×60]  Title           │
│                      ⏱ mm:ss         │
│  ...                                │
└─────────────────────────────────────┘
```

**Video ID extraction** (no `convertUrlToId` — manual URI parse):

```dart
String get videoId {
  final uri = Uri.tryParse(url);
  if (uri == null) return '';
  if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v']!;
  if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty)
    return uri.pathSegments.first;
  return '';
}
```

**Thumbnail URL**: `https://img.youtube.com/vi/{videoId}/mqdefault.jpg`

**Video selection**: disposing old controller + creating new `YoutubePlayerController.fromVideoId(videoId, autoPlay: true)`.

### 6.5 Future: Unit/Item Model (Replacing Mock Playlists)

Current `PlaylistModel` / `VideoModel` will be superseded by `UnitDocument` / `UnitItemDocument` (§2.4/§2.5) when the Firestore curriculum schema is activated.

**Migration path**:
1. Replace `LocalPlaylistsRepository` with `FirestoreUnitsRepository` in `app_router.dart` (single line).
2. Swap `PlaylistModel.fromJson()` with `UnitDocument.fromFirestore()`.
3. `UnitItemDocument` maps `type: "VIDEO"` → inline player; `type: "PDF"` → in-app PDF viewer.

**PDF viewer requirement**: `flutter_pdfview` or `syncfusion_flutter_pdfviewer`; load from Firebase Storage signed URL.

---

## 7. Web Admin Dashboard Specs

> Target: Flutter Web app; separate `lib/admin/` entrypoint. Authenticated via Email/Password (teacher role only).

### 7.1 KPI Bar

| Metric | Firestore Query | Refresh |
|---|---|---|
| Active Users | `count(users WHERE subscription_end_date > now())` | On load + 5 min polling |
| Total Unused Codes | `count(codes WHERE is_redeemed == false)` | On load + on batch generate |
| Total Published Units | `count(units WHERE is_published == true)` | On load + on unit change |
| Total Units (all) | `count(units)` | On load |

### 7.2 Code Generator Module

**Generation logic**:

```
INPUT:  quantity: int, duration_days: int, batch_label: string
OUTPUT: List<CodeDocument>

FOR i in 1..quantity:
  code = generateCode()    // format: XXXX-XXXX-XXXX (uppercase alphanum)
  write /teachers/{tid}/codes/{code} {
    code, duration_days, is_redeemed: false,
    redeemed_by: null, redeemed_at: null,
    created_at: serverTimestamp(), created_by: tid,
    batch_id: batchId,
  }
```

**Code format regex**: `^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$`

**Export specs**:

| Format | Library | Columns |
|---|---|---|
| Excel (`.xlsx`) | `excel` pub package | Code, Duration Days, Created At, Is Redeemed, Redeemed By, Redeemed At |
| PDF | `pdf` pub package | Same columns; branded header with teacher name |

### 7.3 Curriculum Manager

**Unit CRUD**:

| Action | Firestore Op | Notes |
|---|---|---|
| Create Unit | `add()` to `units/` | Sets `is_published: false`, `order_index: count + 1` |
| Edit Unit | `update()` | Title, description, grade, thumbnail |
| Delete Unit | `delete()` unit + all subcollection `items/` | Batch delete |
| Publish/Draft toggle | `update({ is_published: !current })` | Instant; reflected in student app |
| Reorder | `writeBatch()` updating `order_index` on all moved units | Drag-and-drop trigger |

**Item CRUD** (within a Unit):

| Action | Firestore Op | Notes |
|---|---|---|
| Add Video Item | `add()` to `units/{id}/items/` | `type: "VIDEO"`, paste YouTube URL |
| Add PDF Item | Upload to Storage → `add()` with `url: storageUrl` | `type: "PDF"` |
| Reorder Items | `writeBatch()` updating `order_index` | Drag-and-drop |
| Delete Item | `delete()` + `deleteObject()` if PDF | Storage cleanup required |

**File Upload Pipeline** (PDF):

```
1. Teacher selects file (FilePicker)
2. Upload to: /teachers/{teacherId}/units/{unitId}/{filename}
3. getDownloadURL() → store as item.url
4. Progress: StreamController<double> → LinearProgressIndicator in modal
5. On error: deleteObject() to clean up partial upload
```

**Drag-and-drop ordering** (Flutter Web):

```dart
// Use ReorderableListView.builder
// On reorder:
final batch = db.batch();
for (int i = 0; i < reorderedItems.length; i++) {
  batch.update(itemRef(reorderedItems[i].id), {'order_index': i});
}
await batch.commit();
```

### 7.4 Admin Dashboard Route Map

| Path | Screen | Auth Guard |
|---|---|---|
| `/admin/login` | Teacher Email/Password Login | Public |
| `/admin/dashboard` | KPI Bar + Quick Actions | `role == "teacher"` |
| `/admin/codes` | Code Listing + Generator | `role == "teacher"` |
| `/admin/curriculum` | Unit list + Drag reorder | `role == "teacher"` |
| `/admin/curriculum/:unitId` | Item list + Add/Edit items | `role == "teacher"` |
| `/admin/students` | Student list + subscription status | `role == "teacher"` |

---

## 8. API Contract Reference

### 8.1 FirestoreService Method Signatures

```dart
class FirestoreService {
  // ── Users ──────────────────────────────────────────────────────────
  Future<UserEntity?>  getUserDocument(String uid, {String? teacherId});
  Future<void>         saveUserProfile({required String uid, required String fullName,
                           required String studentPhone, required String parentPhone,
                           required String academicGrade, String? email,
                           required String teacherId});
  // ── Subscription ───────────────────────────────────────────────────
  Future<UserEntity>   redeemCode({required String uid, required String code,
                           required String teacherId});
  // ── Units ──────────────────────────────────────────────────────────
  Future<List<UnitDocument>>     getPublishedUnits({required String teacherId,
                                     required String academicGrade});
  Future<List<UnitItemDocument>> getUnitItems({required String teacherId,
                                     required String unitId});
  // ── Admin: Codes ───────────────────────────────────────────────────
  Future<void>         generateCodes({required String teacherId,
                           required int quantity, required int durationDays,
                           required String batchId});
  Future<List<CodeDocument>> listCodes({required String teacherId,
                                bool redeemedOnly = false});
  // ── Admin: Units ───────────────────────────────────────────────────
  Future<String>  createUnit({required String teacherId, required UnitDocument unit});
  Future<void>    updateUnit({required String teacherId, required UnitDocument unit});
  Future<void>    deleteUnit({required String teacherId, required String unitId});
  Future<void>    reorderUnits({required String teacherId,
                      required List<String> orderedIds});
  Future<String>  addItem({required String teacherId, required String unitId,
                      required UnitItemDocument item});
  Future<void>    deleteItem({required String teacherId, required String unitId,
                      required String itemId});
  Future<void>    reorderItems({required String teacherId, required String unitId,
                      required List<String> orderedIds});
}
```

### 8.2 Repository Abstraction Layer

```dart
abstract class UnitsRepository {
  Future<List<UnitDocument>> getUnitsByGrade(String grade);
}

class FirestoreUnitsRepository implements UnitsRepository {
  // Production implementation; swap in app_router.dart:
  // BlocProvider(create: (_) => UnitsCubit(repository: FirestoreUnitsRepository(
  //   firestoreService: FirestoreService(), teacherId: teacherId)));
}

class MockUnitsRepository implements UnitsRepository {
  // Development stub; currently active in app_router.dart via LocalPlaylistsRepository.
  // TODO: Remove when FirestoreUnitsRepository is activated.
}
```

### 8.3 Cubit Method / State Contracts

**SubscriptionCubit**:

```dart
void   checkSubscriptionStatus(UserEntity user);   // → Active | Expired
Future redeemCode({required UserEntity user, required String code}); // → Active | Failure
void   reset();                                    // → Initial
```

**PlaylistsCubit** (current stub) / **UnitsCubit** (future):

```dart
Future loadPlaylistsByGrade(String grade);         // → Loading → Loaded | Error
```

---

## Appendix A: File Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── blocs/
│   ├── auth/         auth_bloc.dart | auth_event.dart | auth_state.dart
│   ├── courses/      courses_cubit.dart | courses_state.dart
│   ├── playlists/    playlists_cubit.dart | playlists_state.dart
│   ├── settings/     settings_cubit.dart | settings_state.dart
│   └── subscription/ subscription_cubit.dart | subscription_state.dart
├── constants/
│   └── app_strings.dart
├── models/
│   ├── course_model.dart
│   ├── playlist_model.dart     ← current; maps to UnitDocument (future)
│   └── user_entity.dart
├── repositories/
│   ├── courses_repository.dart
│   └── playlists_repository.dart  ← LocalPlaylistsRepository (JSON asset stub)
├── router/
│   └── app_router.dart
├── screens/
│   ├── auth/         login_screen.dart | complete_profile_screen.dart | signup_screen.dart
│   ├── dashboard/    dashboard_screen.dart
│   ├── learning/     learning_path_screen.dart | lesson_screen.dart | quiz_screen.dart
│   ├── playlists/    playlist_detail_screen.dart
│   └── settings/     settings_screen.dart
├── services/
│   └── firestore_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── bottom_nav_bar.dart
    ├── custom_text_field.dart
    └── redeem_code_sheet.dart

assets/
└── data/
    └── playlists.json     ← stub content; replaced by Firestore when units schema is live

android/
├── app/
│   ├── build.gradle.kts   compileSdk=36, targetSdk=35, minSdk=flutter.minSdkVersion
│   └── google-services.json
└── settings.gradle.kts    AGP 8.11.1, google-services 4.4.2, Kotlin 2.2.20
```

---

## Appendix B: Environment & Build Checksums

| Item | Value |
|---|---|
| Flutter SDK constraint | `^3.10.4` |
| Firebase project ID | `resala-65331` |
| Android package name | `com.example.resala` |
| compileSdk | 36 |
| targetSdk | 35 |
| AGP | 8.11.1 |
| Kotlin | 2.2.20 |
| google-services plugin | 4.4.2 |
| Last clean `flutter analyze` | 2026-09-03 — No issues found |
