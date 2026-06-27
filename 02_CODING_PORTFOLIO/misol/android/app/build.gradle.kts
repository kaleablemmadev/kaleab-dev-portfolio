android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.example.misol"
        minSdkVersion 23
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    // Flutter dependencies
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // Add these for notifications
    implementation 'androidx.core:core:1.12.0'
    implementation 'androidx.work:work-runtime:2.9.0'
}