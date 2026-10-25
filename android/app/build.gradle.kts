import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing config is read from android/key.properties when present
// (created by CI from RELEASE_KEYSTORE_* secrets, or by you locally).
// When absent, we fall back to debug signing so `flutter run --release`
// and unconfigured forks still build.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists().also { exists ->
    if (exists) keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.emberspark.wallet"
    // Pinned to 36 so the build stays valid regardless of Flutter's default
    // (targetSdk must be <= compileSdk).
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications requires core library desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.emberspark.wallet"
        // flutter_zxing (QR scanner) requires at least API 23. This only sets a
        // floor: Flutter's default (currently 24) applies while it is higher.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        // Pinned for Play Store rather than tracking Flutter's default, which
        // lags behind the deadline. Google Play requires targeting Android 16
        // (API 36) for app updates from 31 Aug 2026.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // F-Droid sets ES_UNSIGNED_RELEASE=1: it needs an unsigned APK and
            // signs it with its own key.
            signingConfig = when {
                System.getenv("ES_UNSIGNED_RELEASE") == "1" -> null
                hasReleaseSigning -> signingConfigs.getByName("release")
                else -> signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Split APKs get versionCode * 10 + ABI (the F-Droid scheme) instead of
// Flutter's ABI * 1000 + versionCode. Runs after Flutter's override, so it
// wins. The App Bundle keeps the plain versionCode.
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val abiVersionCode = abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]
        if (abiVersionCode != null) {
            (output as ApkVariantOutputImpl).versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required by flutter_local_notifications (core library desugaring).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
