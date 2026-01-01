import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val envProperties = Properties()
val envFile = rootProject.file("../.env")
if (envFile.exists()) {
    envFile.forEachLine { line ->
        val trimmed = line.trim()
        if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
            val entry = if (trimmed.startsWith("export ")) trimmed.substring(7).trim() else trimmed
            if (entry.contains("=")) {
                val parts = entry.split("=", limit = 2)
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
            val alias = envProperties["ANDROID_KEY_ALIAS"]?.toString() ?: System.getenv("ANDROID_KEY_ALIAS")
            val keyPass = envProperties["ANDROID_KEY_PASSWORD"]?.toString() ?: System.getenv("ANDROID_KEY_PASSWORD")
            val storePass = envProperties["ANDROID_KEYSTORE_PASSWORD"]?.toString() ?: System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val keystoreFile = file("upload-keystore.jks")

            if (alias != null && keyPass != null && storePass != null && keystoreFile.exists()) {
                keyAlias = alias
                keyPassword = keyPass
                storeFile = keystoreFile
                storePassword = storePass
            } else {
                // Fallback to debug signing if release info is missing
                // This allows `flutter run` to work without a setup keystore
                val debugConfig = signingConfigs.getByName("debug")
                keyAlias = debugConfig.keyAlias
                keyPassword = debugConfig.keyPassword
                storeFile = debugConfig.storeFile
                storePassword = debugConfig.storePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
