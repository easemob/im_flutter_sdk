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

// file_picker 8.3.7 hardcodes compileSdk 34, but newer dependencies (e.g.
// flutter_plugin_android_lifecycle) require compileSdk 36+. AGP rejects the
// mismatch in checkDebugAarMetadata, so align plugin modules here.
subprojects {
    afterEvaluate {
        extensions
            .findByType(com.android.build.api.dsl.CommonExtension::class.java)
            ?.let { it.compileSdk = 36 }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
