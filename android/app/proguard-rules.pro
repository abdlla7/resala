# ─── Flutter ──────────────────────────────────────────────────────────────────
# Flutter engine JNI bridge — must not be stripped or renamed.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ─── Firebase ─────────────────────────────────────────────────────────────────
# Firebase uses reflection internally; keep all Firebase classes.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firestore model serialization — keeps data class fields intact.
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
}

# ─── Kotlin ───────────────────────────────────────────────────────────────────
# Kotlin coroutines & serialization reflection.
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Lazy {
    <fields>;
}

# ─── Google Sign-In ───────────────────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }

# ─── General Android ─────────────────────────────────────────────────────────
# Keep Parcelable implementations.
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep enum values (accessed by name via reflection in some libs).
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Suppress warnings for classes not present in the classpath.
-dontwarn com.google.**
-dontwarn io.flutter.**
