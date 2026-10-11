package com.emberspark.wallet

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.activity.enableEdgeToEdge
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var ringtone: Ringtone? = null
    private var flightModeReceiver: BroadcastReceiver? = null

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
        // Streams the flight-mode (airplane mode) setting: the current value on
        // listen, then every change via the system broadcast. Lets Home show a
        // calm "flight mode" state instead of a red connection error.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, FLIGHT_MODE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    events.success(isFlightModeOn())
                    val receiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            events.success(isFlightModeOn())
                        }
                    }
                    flightModeReceiver = receiver
                    ContextCompat.registerReceiver(
                        this@MainActivity,
                        receiver,
                        IntentFilter(Intent.ACTION_AIRPLANE_MODE_CHANGED),
                        ContextCompat.RECEIVER_NOT_EXPORTED,
                    )
                }

                override fun onCancel(arguments: Any?) {
                    flightModeReceiver?.let { unregisterReceiver(it) }
                    flightModeReceiver = null
                }
            })
    }

    private fun isFlightModeOn(): Boolean =
        Settings.Global.getInt(contentResolver, Settings.Global.AIRPLANE_MODE_ON, 0) != 0

    override fun onDestroy() {
        flightModeReceiver?.let { unregisterReceiver(it) }
        flightModeReceiver = null
        super.onDestroy()
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
        private const val FLIGHT_MODE_CHANNEL = "emberspark/flight_mode"
    }
}
