plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing — requires android/key.properties ────────────────────────
// The file is excluded from version control via .gitignore.
// CI/CD pipelines must write it before invoking `flutter build apk --release`
// or `flutter build appbundle`.  A missing file causes an explicit build
// failure rather than silently shipping a debug-signed binary to the store.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = java.util.Properties()
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

android {
    namespace = "com.muhammedelshreay.resala"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.muhammedelshreay.resala"
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Always declare the release config; values are populated from
        // key.properties.  If the file is absent we will fail below in
        // buildTypes so the error is surfaced at the right point.
        if (keyPropertiesFile.exists()) {
            create("release") {
                keyAlias      = keyProperties["keyAlias"]     as String
                keyPassword   = keyProperties["keyPassword"]  as String
                storeFile     = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ── Signing ───────────────────────────────────────────────────
            // Fail loudly if key.properties is missing so we never
            // accidentally publish a debug-signed binary to the Play Store.
            if (!keyPropertiesFile.exists()) {
                error(
                    "Release build requires android/key.properties. " +
                    "Create the file with storeFile, storePassword, " +
                    "keyAlias, and keyPassword entries."
                )
            }
            signingConfig = signingConfigs.getByName("release")

            // ── R8 shrinking & obfuscation ────────────────────────────────
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
