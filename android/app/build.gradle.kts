plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.jardineritoapp"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = flutter.ndkVersion

    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.jardineritoapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName

        // Configuraciones específicas para Bluetooth
        manifestPlaceholders += mapOf(
            "usesCleartextTraffic" to "false",
            "android.hardware.bluetooth" to "true",
            "android.hardware.bluetooth_le" to "true"
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Optimización para release
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Configuración para desarrollo
            isDebuggable = true
        }
    }

    // Soporte para Java 11 features
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    // Para habilitar Java 8+ APIs en versiones anteriores de Android
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Dependencias para Bluetooth (si es necesario)
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}

flutter {
    source = "../.."
}