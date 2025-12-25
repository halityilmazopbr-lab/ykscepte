// Root-level extra properties (accessible by all subprojects)
extra["compileSdkVersion"] = 35
extra["minSdkVersion"] = 21
extra["targetSdkVersion"] = 35

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
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

// Subprojects için compileSdkVersion ayarla (app_links vb. üçüncü parti paketler için)
// KOŞULSUZ OVERRIDE - tüm pluginleri SDK 35'e zorla
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExtension = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (androidExtension != null) {
            // Koşulsuz olarak 35 yap (plugin'in kendi değerini eziyoruz)
            androidExtension.compileSdkVersion(35)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

