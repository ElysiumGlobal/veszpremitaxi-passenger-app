package hu.veszpremitaxi.passenger

import android.media.AudioAttributes
import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterFragmentActivity() {
    private companion object {
        const val ARRIVAL_SOUND_CHANNEL =
            "hu.veszpremitaxi.passenger/arrival_sound"
    }

    private var arrivalSoundPlayer: MediaPlayer? = null
    private var arrivalSoundFile: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ARRIVAL_SOUND_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playWhistle" -> {
                    val audioBytes = call.arguments as? ByteArray
                    if (audioBytes == null || audioBytes.isEmpty()) {
                        result.success(false)
                    } else {
                        result.success(playArrivalWhistle(audioBytes))
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        releaseArrivalSound()
        super.onDestroy()
    }

    private fun playArrivalWhistle(audioBytes: ByteArray): Boolean {
        releaseArrivalSound()

        return try {
            val soundFile = File.createTempFile(
                "taxi_arrived_whistle_",
                ".wav",
                cacheDir,
            )
            FileOutputStream(soundFile).use { output ->
                output.write(audioBytes)
                output.flush()
            }

            val player = MediaPlayer()
            arrivalSoundFile = soundFile
            arrivalSoundPlayer = player

            player.apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(soundFile.absolutePath)
                setVolume(1.0f, 1.0f)
                setOnCompletionListener {
                    releaseArrivalSound()
                }
                setOnErrorListener { _, _, _ ->
                    releaseArrivalSound()
                    true
                }
                prepare()
                start()
            }
            true
        } catch (_: Exception) {
            releaseArrivalSound()
            false
        }
    }

    private fun releaseArrivalSound() {
        arrivalSoundPlayer?.runCatching {
            if (isPlaying) {
                stop()
            }
        }
        arrivalSoundPlayer?.release()
        arrivalSoundPlayer = null

        arrivalSoundFile?.delete()
        arrivalSoundFile = null
    }
}
