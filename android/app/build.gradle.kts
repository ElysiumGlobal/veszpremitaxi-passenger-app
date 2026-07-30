import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

val googleMapsApiKey =
    localProperties.getProperty("google.maps.api.key")
        ?: providers.gradleProperty("GOOGLE_MAPS_API_KEY").orNull
        ?: System.getenv("GOOGLE_MAPS_API_KEY")
        ?: ""

val cmKeystorePath = System.getenv("CM_KEYSTORE_PATH")
val cmKeystorePassword = System.getenv("CM_KEYSTORE_PASSWORD")
val cmKeyAlias = System.getenv("CM_KEY_ALIAS")
val cmKeyPassword = System.getenv("CM_KEY_PASSWORD")

val hasCodemagicSigning =
    !cmKeystorePath.isNullOrBlank() &&
        !cmKeystorePassword.isNullOrBlank() &&
        !cmKeyAlias.isNullOrBlank() &&
        !cmKeyPassword.isNullOrBlank()

val localStoreFile = keystoreProperties.getProperty("storeFile")
val localStorePassword = keystoreProperties.getProperty("storePassword")
val localKeyAlias = keystoreProperties.getProperty("keyAlias")
val localKeyPassword = keystoreProperties.getProperty("keyPassword")

val hasKeyPropertiesSigning =
    !localStoreFile.isNullOrBlank() &&
        !localStorePassword.isNullOrBlank() &&
        !localKeyAlias.isNullOrBlank() &&
        !localKeyPassword.isNullOrBlank()

val hasStableSigning = hasCodemagicSigning || hasKeyPropertiesSigning

android {
    namespace = "hu.veszpremitaxi.passenger"
    compileSdk = 36

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "hu.veszpremitaxi.passenger"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    signingConfigs {
        create("stable") {
            when {
                hasCodemagicSigning -> {
                    storeFile = file(cmKeystorePath!!)
                    storePassword = cmKeystorePassword
                    keyAlias = cmKeyAlias
                    keyPassword = cmKeyPassword
                }

                hasKeyPropertiesSigning -> {
                    storeFile = file(localStoreFile!!)
                    storePassword = localStorePassword
                    keyAlias = localKeyAlias
                    keyPassword = localKeyPassword
                }
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // A Codemagic belso teszt-APK is ugyanazzal az allando kulccsal keszul.
            // Ha nincs CI/local signing konfiguracio, helyi fejlesztesnel marad a normal debug kulcs.
            if (hasStableSigning) {
                signingConfig = signingConfigs.getByName("stable")
            }
        }

        getByName("release") {
            if (!hasStableSigning) {
                throw GradleException(
                    "Hianyzik az allando Android alairas. Allitsd be a Codemagic code signingot " +
                        "vagy az android/key.properties fajlt."
                )
            }
            signingConfig = signingConfigs.getByName("stable")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.appcompat:appcompat:1.4.0")
}
