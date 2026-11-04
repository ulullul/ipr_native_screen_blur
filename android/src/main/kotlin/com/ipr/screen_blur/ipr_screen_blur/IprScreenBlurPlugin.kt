package com.ipr.screen_blur.ipr_screen_blur

import android.app.Activity
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/**
 * Screen protection through `FLAG_SECURE` on the current Activity's window.
 *
 * The requested mode is kept independently of the Activity, so a call made while no Activity
 * is attached (app in background) or across Activity recreation is applied on (re)attach.
 */
class IprScreenBlurPlugin :
    FlutterPlugin,
    ActivityAware,
    SecureScreenHostApi {
    private var eventChannel: StreamScreenEventsEventChannel? = null

    private var activity: Activity? = null
    private var secureModeEnabled = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        SecureScreenHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        // No Android events yet (screenshot/recording callbacks need API 34/35). The handler is
        // registered so listening from Dart doesn't fail.
        eventChannel =
            StreamScreenEventsStreamHandler.register(
                flutterPluginBinding.binaryMessenger,
                object : StreamScreenEventsStreamHandler() {}
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        SecureScreenHostApi.setUp(binding.binaryMessenger, null)
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun setSecureMode(enabled: Boolean) {
        secureModeEnabled = enabled
        applySecureFlag()
    }

    // Recording detection needs API 35 (addScreenRecordingCallback); not implemented yet.
    override fun isScreenCaptured(): Boolean = false

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        applySecureFlag()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        applySecureFlag()
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun applySecureFlag() {
        Log.d("ipr_screen_blur", "Applied flag: ${!secureModeEnabled}")
        val window = activity?.window ?: return
        if (secureModeEnabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
