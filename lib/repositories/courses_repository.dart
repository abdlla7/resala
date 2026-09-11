import 'package:flutter/material.dart';
import '../models/course_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abstract interface
// ─────────────────────────────────────────────────────────────────────────────

/// Contract for fetching courses.
///
/// Swap [MockCoursesRepository] for a Firestore-backed implementation once
/// the `/courses` collection schema is finalised — no widget changes needed.
abstract class CoursesRepository {
  /// Returns courses whose [CourseModel.grade] matches [grade].
  Future<List<CourseModel>> getCoursesByGrade(String grade);
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock implementation
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory stub that filters [_kMockCourses] by grade locally.
///
/// TODO: Replace with FirestoreCoursesRepository:
///   ```dart
///   class FirestoreCoursesRepository implements CoursesRepository {
///     final FirebaseFirestore _db = FirebaseFirestore.instance;
///
///     @override
///     Future<List<CourseModel>> getCoursesByGrade(String grade) async {
///       final snap = await _db
///           .collection('courses')
///           .where('grade', isEqualTo: grade)
///           .orderBy('order')
///           .get();
///       return snap.docs
///           .map((d) => CourseModel.fromFirestore(d.data(), d.id))
///           .toList();
///     }
///   }
///   ```
class MockCoursesRepository implements CoursesRepository {
  const MockCoursesRepository();

  @override
  Future<List<CourseModel>> getCoursesByGrade(String grade) async {
    // Simulate a short network round-trip.
    await Future.delayed(const Duration(milliseconds: 350));
    return _kMockCourses.where((c) => c.grade == grade).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock catalogue – one entry per subject × grade
// ─────────────────────────────────────────────────────────────────────────────

const List<CourseModel> _kMockCourses = [
  // ── الأول الإعدادي ──────────────────────────────────────────────────────
  CourseModel(
    id: 'prep1_math',
    title: 'الرياضيات',
    description: 'أساسيات الأرقام والعمليات الحسابية للصف الأول الإعدادي.',
    grade: '1st_prep',
    progress: 0.6,
    status: CourseStatus.inProgress,
    totalLessons: 10,
    completedLessons: 6,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'prep1_arabic',
    title: 'اللغة العربية',
    description: 'النحو والإملاء والقراءة للمرحلة الإعدادية الأولى.',
    grade: '1st_prep',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 8,
    completedLessons: 0,
    subjectIcon: Icons.auto_stories,
  ),
  CourseModel(
    id: 'prep1_science',
    title: 'العلوم',
    description: 'مقدمة في الفيزياء والكيمياء وعلم الأحياء.',
    grade: '1st_prep',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 12,
    completedLessons: 0,
    subjectIcon: Icons.science,
  ),

  // ── الثاني الإعدادي ──────────────────────────────────────────────────────
  CourseModel(
    id: 'prep2_math',
    title: 'الرياضيات',
    description: 'الجبر والهندسة للصف الثاني الإعدادي.',
    grade: '2nd_prep',
    progress: 0.4,
    status: CourseStatus.inProgress,
    totalLessons: 10,
    completedLessons: 4,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'prep2_english',
    title: 'اللغة الإنجليزية',
    description: 'مهارات القراءة والكتابة والمحادثة باللغة الإنجليزية.',
    grade: '2nd_prep',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 9,
    completedLessons: 0,
    subjectIcon: Icons.language,
  ),
  CourseModel(
    id: 'prep2_science',
    title: 'العلوم',
    description: 'الخصائص الفيزيائية والكيميائية للمادة.',
    grade: '2nd_prep',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 11,
    completedLessons: 0,
    subjectIcon: Icons.science,
  ),

  // ── الثالث الإعدادي ──────────────────────────────────────────────────────
  CourseModel(
    id: 'prep3_math',
    title: 'الرياضيات',
    description: 'المعادلات التربيعية والدوال للصف الثالث الإعدادي.',
    grade: '3rd_prep',
    progress: 0.7,
    status: CourseStatus.inProgress,
    totalLessons: 14,
    completedLessons: 10,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'prep3_arabic',
    title: 'اللغة العربية',
    description: 'البلاغة والأدب والنصوص الأدبية للمرحلة الإعدادية.',
    grade: '3rd_prep',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 8,
    completedLessons: 0,
    subjectIcon: Icons.auto_stories,
  ),
  CourseModel(
    id: 'prep3_science',
    title: 'العلوم',
    description: 'أساسيات الفيزياء والكيمياء والأحياء كمدخل للثانوية.',
    grade: '3rd_prep',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 15,
    completedLessons: 0,
    subjectIcon: Icons.science,
  ),

  // ── الأول الثانوي ────────────────────────────────────────────────────────
  CourseModel(
    id: 'sec1_math',
    title: 'الرياضيات',
    description: 'الجبر المتقدم والهندسة الفضائية للصف الأول الثانوي.',
    grade: '1st_secondary',
    progress: 0.5,
    status: CourseStatus.inProgress,
    totalLessons: 16,
    completedLessons: 8,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'sec1_physics',
    title: 'الفيزياء',
    description: 'الميكانيكا والديناميكا الحرارية والضوء.',
    grade: '1st_secondary',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 14,
    completedLessons: 0,
    subjectIcon: Icons.bolt,
  ),
  CourseModel(
    id: 'sec1_chemistry',
    title: 'الكيمياء',
    description: 'التفاعلات الكيميائية والجدول الدوري للعناصر.',
    grade: '1st_secondary',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 12,
    completedLessons: 0,
    subjectIcon: Icons.science,
  ),

  // ── الثاني الثانوي ───────────────────────────────────────────────────────
  CourseModel(
    id: 'sec2_math',
    title: 'الرياضيات',
    description: 'حساب المثلثات والإحصاء والاحتمالات.',
    grade: '2nd_secondary',
    progress: 0.3,
    status: CourseStatus.inProgress,
    totalLessons: 18,
    completedLessons: 5,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'sec2_biology',
    title: 'علم الأحياء',
    description: 'الخلية والوراثة وتشريح الجسم البشري.',
    grade: '2nd_secondary',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 14,
    completedLessons: 0,
    subjectIcon: Icons.biotech,
  ),
  CourseModel(
    id: 'sec2_english',
    title: 'اللغة الإنجليزية',
    description: 'مهارات التحدث والكتابة الأكاديمية المتقدمة.',
    grade: '2nd_secondary',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 10,
    completedLessons: 0,
    subjectIcon: Icons.language,
  ),

  // ── الثالث الثانوي ───────────────────────────────────────────────────────
  CourseModel(
    id: 'sec3_math',
    title: 'الرياضيات',
    description: 'التفاضل والتكامل والمعادلات التفاضلية للثانوية العامة.',
    grade: '3rd_secondary',
    progress: 0.75,
    status: CourseStatus.inProgress,
    totalLessons: 20,
    completedLessons: 15,
    subjectIcon: Icons.calculate,
  ),
  CourseModel(
    id: 'sec3_physics',
    title: 'الفيزياء',
    description: 'الكهرباء والمغناطيسية والفيزياء الحديثة.',
    grade: '3rd_secondary',
    progress: 0.0,
    status: CourseStatus.notStarted,
    totalLessons: 16,
    completedLessons: 0,
    subjectIcon: Icons.bolt,
  ),
  CourseModel(
    id: 'sec3_chemistry',
    title: 'الكيمياء',
    description: 'الكيمياء العضوية وغير العضوية للثانوية العامة.',
    grade: '3rd_secondary',
    progress: 0.0,
    status: CourseStatus.locked,
    totalLessons: 14,
    completedLessons: 0,
    subjectIcon: Icons.science,
  ),
];
