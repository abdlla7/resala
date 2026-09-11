allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            val android = extensions.findByName("android")
            if (android != null) {
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android) as String?
                    if (currentNamespace.isNullOrEmpty()) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        val name = project.name.replace(".", "_").replace("-", "_")
                        val injectedNamespace = when (project.name) {
                            "firebase_auth" -> "io.flutter.plugins.firebase.auth"
                            "firebase_core" -> "io.flutter.plugins.firebase.core"
                            "shared_preferences_android" -> "io.flutter.plugins.sharedpreferences"
                            "url_launcher_android" -> "io.flutter.plugins.urllauncher"
                            "webview_flutter_android" -> "io.flutter.plugins.webviewflutter"
                            else -> "com.example.resala.$name"
                        }
                        setNamespace.invoke(android, injectedNamespace)
                        println("Injected namespace '$injectedNamespace' into project ':${project.name}'")
                    }
                } catch (e: Exception) {
                    // Method might not exist or other reflection error
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
