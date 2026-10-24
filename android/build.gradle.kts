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
    project.evaluationDependsOn(":app")
}

// Plugins that set no ndkVersion (e.g. flutter_zxing, which builds zxing-cpp)
// would fall back to AGP's default NDK. Build them with the app's NDK, so a
// single NDK is enough (F-Droid installs only the one its recipe names). A
// plugin's own ndkVersion is applied later and still wins.
subprojects {
    plugins.withId("com.android.library") {
        val appNdk = project(":app").extensions
            .getByType<com.android.build.api.dsl.ApplicationExtension>().ndkVersion
        extensions.configure<com.android.build.api.dsl.LibraryExtension> {
            ndkVersion = appNdk
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
