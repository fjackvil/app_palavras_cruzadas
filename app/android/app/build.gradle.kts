import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Chave de assinatura (upload) para a Play Store. O arquivo key.properties
// e a chave .jks ficam só no computador: estão no .gitignore e NUNCA vão
// para o git. Sem key.properties, o release usa a chave de teste (debug).
val chaveProps = Properties()
val chaveArquivo = rootProject.file("key.properties")
if (chaveArquivo.exists()) {
    chaveProps.load(FileInputStream(chaveArquivo))
}

android {
    namespace = "com.vileladigit.palavrascruzadas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vileladigit.palavrascruzadas"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (chaveArquivo.exists()) {
            create("upload") {
                keyAlias = chaveProps["keyAlias"] as String
                keyPassword = chaveProps["keyPassword"] as String
                storeFile = file(chaveProps["storeFile"] as String)
                storePassword = chaveProps["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (chaveArquivo.exists()) {
                signingConfigs.getByName("upload")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
