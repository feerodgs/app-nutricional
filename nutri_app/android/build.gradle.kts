plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // 🔹 Plugin do Firebase
}

android {
    namespace "com.example.nutri_app"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.nutri_app" // 🔹 mesmo que você registrou no Firebase
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.10.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "com.google.android.material:material:1.9.0"

    // 🔹 Firebase
    implementation platform("com.google.firebase:firebase-bom:33.3.0")
    implementation "com.google.firebase:firebase-analytics"
    implementation "com.google.firebase:firebase-auth"
    implementation "com.google.firebase:firebase-firestore"
}
