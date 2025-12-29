import java.text.SimpleDateFormat
import java.util.Date
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.paddyliu.idiom_puzzle"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.paddyliu.idiom_puzzle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    applicationVariants.all {
        val variant = this
        val appName = "idiom_puzzle"
        val version = variant.versionName
        val date = SimpleDateFormat("yyyyMMdd").format(Date())
        val newFileName = "$appName-v$version-$date-${variant.name}"

        // 1. Rename APK directly in the build output
        variant.outputs.forEach { output ->
            if (output is com.android.build.gradle.api.ApkVariantOutput) {
                output.outputFileName = "$newFileName.apk"
            }
        }
        
        // Register finalize task for APK
        if (variant.name == "release") {
            variant.assembleProvider.configure {
                finalizedBy("copyReleaseApk")
            }
        }
    }
}

// 2. Custom Task to Copy and Rename AAB to a separate folder
tasks.whenTaskAdded {
    if (name == "bundleRelease") {
        finalizedBy("copyReleaseBundle")
    }
}

tasks.register<Copy>("copyReleaseBundle") {
    val appName = "idiom_puzzle"
    val version = flutter.versionName
    val date = SimpleDateFormat("yyyyMMdd").format(Date())
    val newName = "$appName-v$version-$date-release.aab"

    from("$buildDir/outputs/bundle/release/app-release.aab")
    into("$buildDir/outputs/final/")
    rename("app-release.aab", newName)
    
    doLast {
        println("AAB successfully copied to: build/app/outputs/final/$newName")
    }
}

// 3. Custom Task to Copy APK to the same final folder
tasks.register<Copy>("copyReleaseApk") {
    val appName = "idiom_puzzle"
    val version = flutter.versionName
    val date = SimpleDateFormat("yyyyMMdd").format(Date())
    val fileName = "$appName-v$version-$date-release.apk"

    // 因為 APK 已經在 variant.outputs 中被改名了，我們需要從那裡複製
    // 但為了確保簡單，我們直接掃描 release 目錄下的該檔案
    from("$buildDir/outputs/apk/release/$fileName")
    into("$buildDir/outputs/final/")
    
    doLast {
        println("APK successfully copied to: build/app/outputs/final/$fileName")
    }
}

flutter {
    source = "../.."
}