import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

val hasReleaseSigning =
    !keyProperties.getProperty("storeFile").isNullOrBlank() &&
        !keyProperties.getProperty("storePassword").isNullOrBlank() &&
        !keyProperties.getProperty("keyAlias").isNullOrBlank() &&
        !keyProperties.getProperty("keyPassword").isNullOrBlank()

android {
    namespace = "com.example.tras_phone"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.example.tras_phone"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val mapsApiKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            buildConfigField("boolean", "SECURITY_ENFORCEMENT_ENABLED", "false")
        }

        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            buildConfigField("boolean", "SECURITY_ENFORCEMENT_ENABLED", "true")

            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:integrity:1.4.0")
}

flutter {
    source = "../.."
}
