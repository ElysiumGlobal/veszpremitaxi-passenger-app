package hu.veszpremitaxi.passenger

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private companion object {
        const val AUDIO_CHANNEL = "hu.veszpremitaxi.passenger/audio"
        const val SCREEN_AWAKE_CHANNEL = "hu.veszpremitaxi.passenger/screen_awake"
    }

    private var soundPlayer: MediaPlayer? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private val audioManager: AudioManager by lazy {
        getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playArrivalWhistle" -> result.success(
                    playNativeSound(
                        R.raw.vtaxi_arrival_whistle,
                        AudioAttributes.USAGE_ALARM,
                        AudioManager.STREAM_ALARM,
                    ),
                )
                "playChatBeep" -> result.success(
                    playNativeSound(
                        R.raw.vtaxi_chat_beep,
                        AudioAttributes.USAGE_NOTIFICATION_EVENT,
                        AudioManager.STREAM_NOTIFICATION,
                    ),
                )
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_AWAKE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "setKeepAwake") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val keepAwake = call.arguments as? Boolean ?: false
            runOnUiThread {
                if (keepAwake) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                }
            }
            result.success(null)
        }
    }

    override fun onDestroy() {
        releaseSound()
        super.onDestroy()
    }

    private fun playNativeSound(
        resourceId: Int,
        usage: Int,
        legacyStream: Int,
    ): Boolean {
        releaseSound()

        return try {
            val attributes = AudioAttributes.Builder()
                .setUsage(usage)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            requestAudioFocus(attributes, legacyStream)

            val afd = resources.openRawResourceFd(resourceId) ?: return false
            val player = MediaPlayer()
            soundPlayer = player

            try {
                player.setAudioAttributes(attributes)
                player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            } finally {
                afd.close()
            }

            player.setVolume(1.0f, 1.0f)
            player.setOnCompletionListener { releaseSound() }
            player.setOnErrorListener { _, _, _ ->
                releaseSound()
                true
            }
            player.prepare()
            player.start()
            true
        } catch (_: Exception) {
            releaseSound()
            false
        }
    }

    private fun requestAudioFocus(attributes: AudioAttributes, legacyStream: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(attributes)
                .setAcceptsDelayedFocusGain(false)
                .setOnAudioFocusChangeListener { }
                .build()
            audioFocusRequest = request
            audioManager.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                null,
                legacyStream,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
            )
        }
    }

    private fun releaseSound() {
        soundPlayer?.runCatching {
            if (isPlaying) stop()
        }
        soundPlayer?.release()
        soundPlayer = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(null)
        }
    }
}
