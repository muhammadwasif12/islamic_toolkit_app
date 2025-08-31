plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") 
    id("com.google.gms.google-services")

}

android {
    namespace = "com.example.islamic_toolkit_app"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.islamic_toolkit_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
        // Google Mobile Ads SDK (AdMob)
    implementation("com.google.android.gms:play-services-ads:23.1.0")
   // ✅ Firebase BoM (always required for Firebase libs)
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // ✅ Sirf FCM (Firebase Cloud Messaging)
    implementation("com.google.firebase:firebase-messaging")

}

