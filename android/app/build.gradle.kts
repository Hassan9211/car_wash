import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { inputStream ->
        localProperties.load(inputStream)
    }
}

val googleMapsApiKey = (
    project.findProperty("GOOGLE_MAPS_API_KEY") as String?
    )?.takeIf(String::isNotBlank)
    ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY")
        ?.takeIf(String::isNotBlank)
    ?: "YOUR_GOOGLE_MAPS_API_KEY"

android {
    namespace = "com.lavego.carwash"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = file("lavego-release.jks")
            storePassword = "lavego123"
            keyAlias = "lavego"
            keyPassword = "lavego123"
        }
    }

    defaultConfig {
        applicationId = "com.lavego.carwash"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
