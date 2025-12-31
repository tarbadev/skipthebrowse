import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load .env from root
val envProperties = Properties()
val envFile = rootProject.file("../.env")
if (envFile.exists()) {
    envFile.bufferedReader().use { reader ->
        reader.lines().forEach { line ->
            var cleanedLine = line.trim()
            if (cleanedLine.startsWith("export ")) {
                cleanedLine = cleanedLine.substring(7).trim()
            }
            if (cleanedLine.contains("=") && !cleanedLine.startsWith("#")) {
                val parts = cleanedLine.split("=", limit = 2)
                val key = parts[0].trim()
                val value = parts[1].trim().removeSurrounding("\"").removeSurrounding("'")
                envProperties[key] = value
            }
        }
    }
}

android {
    namespace = "com.tarbadev.skipthebrowse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.tarbadev.skipthebrowse"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val alias = envProperties["ANDROID_KEY_ALIAS"] as String? ?: System.getenv("ANDROID_KEY_ALIAS")
            val keyPass = envProperties["ANDROID_KEY_PASSWORD"] as String? ?: System.getenv("ANDROID_KEY_PASSWORD")
            val storePass = envProperties["ANDROID_KEYSTORE_PASSWORD"] as String? ?: System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val keystoreFile = file("upload-keystore.jks")

            if (!keystoreFile.exists()) {
                println("WARNING: Keystore file not found at ${keystoreFile.absolutePath}")
            }

            keyAlias = alias
            keyPassword = keyPass
            storeFile = keystoreFile
            storePassword = storePass
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
