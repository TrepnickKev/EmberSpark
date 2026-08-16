package com.emberspark.wallet

import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var ringtone: Ringtone? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOUND_PREVIEW_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "preview" -> {
                        playPreview(call.argument<String>("sound"))
                        result.success(null)
                    }
                    "stop" -> {
                        ringtone?.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// Plays a short preview of the chosen notification sound so the user can
    /// hear it from the settings dropdown. Uses the same res/raw resources the
    /// notification channel uses, and the system default for "default".
    private fun playPreview(sound: String?) {
        ringtone?.stop()
        val uri: Uri? = when (sound) {
            "coins" -> Uri.parse("android.resource://$packageName/raw/coin_received_coins_handling")
            "woosh" -> Uri.parse("android.resource://$packageName/raw/coin_received_soft_woosh_fire")
            else -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        }
        if (uri == null) return
        ringtone = RingtoneManager.getRingtone(applicationContext, uri)?.apply {
            audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            play()
        }
    }

    companion object {
        private const val SOUND_PREVIEW_CHANNEL = "emberspark/sound_preview"
    }
}
