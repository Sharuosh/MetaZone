import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.net.URL
import java.util.Properties

plugins {
    id("com.google.gms.google-services")
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Read the Google Maps key from android/local.properties, which should not be
// committed to source control. Keep all existing Flutter/Firebase settings.
val localMapsProperties = Properties()
val localMapsPropertiesFile = rootProject.file("local.properties")
if (localMapsPropertiesFile.exists()) {
    localMapsPropertiesFile.inputStream().use { localMapsProperties.load(it) }
}
val mapsApiKey = localMapsProperties.getProperty("MAPS_API_KEY", "")

android {
    namespace = "com.example.meta_zone"

    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }


    defaultConfig {
        applicationId = "com.example.meta_zone"
        minSdk = 33
        targetSdk = 36
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.fromTarget("11")
    }
}

flutter {
    source = "../.."
}

repositories {
    flatDir {
        dirs("libs")
    }
}

dependencies {
    // ---------------------------------------------------------------------
    // Existing MetaZone Flutter + Unity integration
    // ---------------------------------------------------------------------
    implementation(project(":unityLibrary"))

    // Existing Unity/ARCore AARs used by the working native AR path.
    implementation(files("../unityLibrary/libs/arcore_client.aar"))
    implementation(files("../unityLibrary/libs/ARPresto.aar"))
    implementation(files("../unityLibrary/libs/UnityARCore.aar"))
    implementation(files("../unityLibrary/libs/unityandroidpermissions.aar"))

    // ---------------------------------------------------------------------
    // Existing ML Kit compatibility layer.
    // ---------------------------------------------------------------------
    implementation("com.google.mlkit:object-detection:17.0.2")
    implementation("com.google.mlkit:image-labeling:17.0.9")

    // ---------------------------------------------------------------------
    // MetaZone Sense Vision Core.
    // The actual perception tasks are initialized by the native Vision
    // engine; this dependency only provides the runtime.
    // ---------------------------------------------------------------------
    implementation("com.google.mediapipe:tasks-vision:1.0.0")
}

/*
 * ==========================================================================
 * MetaZone Sense Vision model provisioning
 * ==========================================================================
 *
 * Official task/model files are copied into the APK assets directory:
 *
 *   android/app/src/main/assets/metazone_vision/
 *
 * The task is safe to run repeatedly. Existing non-empty files are retained.
 */

val metazoneVisionModels =
    linkedMapOf(
        "face_landmarker.task" to
                "https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task",

        "pose_landmarker_full.task" to
                "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/1/pose_landmarker_full.task",

        "hand_landmarker.task" to
                "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task",

        "gesture_recognizer.task" to
                "https://storage.googleapis.com/mediapipe-models/gesture_recognizer/gesture_recognizer/float16/1/gesture_recognizer.task",

        "holistic_landmarker.task" to
                "https://storage.googleapis.com/mediapipe-models/holistic_landmarker/holistic_landmarker/float16/1/holistic_landmarker.task",

        "efficientdet_lite0.tflite" to
                "https://storage.googleapis.com/mediapipe-models/object_detector/efficientdet_lite0/float32/1/efficientdet_lite0.tflite",
    )

val downloadMetaZoneVisionModels =
    tasks.register("downloadMetaZoneVisionModels") {
        group = "metazone"
        description =
            "Downloads MetaZone Sense Vision model assets."

        doLast {
            val assetsDir =
                file("src/main/assets/metazone_vision")

            assetsDir.mkdirs()

            metazoneVisionModels.forEach { entry ->
                val fileName = entry.key
                val remoteUrl = entry.value
                val destination =
                    file("${assetsDir.absolutePath}/$fileName")

                if (
                    destination.exists() &&
                    destination.length() > 0L
                ) {
                    logger.lifecycle(
                        "MetaZone Vision model already present: $fileName"
                    )
                    return@forEach
                }

                val partial =
                    file("${destination.absolutePath}.part")

                if (partial.exists()) {
                    partial.delete()
                }

                logger.lifecycle(
                    "Downloading MetaZone Vision model: $fileName"
                )

                try {
                    val connection: java.net.URLConnection =
                        URL(remoteUrl).openConnection()

                    connection.connectTimeout = 60_000
                    connection.readTimeout = 180_000
                    connection.useCaches = false

                    connection.getInputStream().use { input ->
                        partial.outputStream().use { output ->
                            input.copyTo(
                                output,
                                1024 * 1024,
                            )
                        }
                    }

                    if (
                        !partial.exists() ||
                        partial.length() <= 0L
                    ) {
                        throw GradleException(
                            "Downloaded model is empty: $fileName"
                        )
                    }

                    if (
                        destination.exists() &&
                        !destination.delete()
                    ) {
                        throw GradleException(
                            "Unable to replace existing model: $fileName"
                        )
                    }

                    if (!partial.renameTo(destination)) {
                        throw GradleException(
                            "Unable to finalize downloaded model: $fileName"
                        )
                    }

                    logger.lifecycle(
                        "MetaZone Vision model ready: $fileName " +
                                "(${destination.length()} bytes)"
                    )
                } catch (t: Throwable) {
                    if (partial.exists()) {
                        partial.delete()
                    }

                    throw GradleException(
                        "Failed to download MetaZone Vision model " +
                                "'$fileName' from $remoteUrl",
                        t,
                    )
                }
            }
        }
    }

tasks.named("preBuild").configure {
    dependsOn(downloadMetaZoneVisionModels)
}
