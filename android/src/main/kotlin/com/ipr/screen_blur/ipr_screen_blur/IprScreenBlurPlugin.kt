package com.ipr.screen_blur.ipr_screen_blur

import android.app.Activity
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Screen protection through `FLAG_SECURE` on the current Activity's window.
 *
 * The requested mode is kept independently of the Activity, so a call made while no Activity
 * is attached (app in background) or across Activity recreation is applied on (re)attach.
 */
class IprScreenBlurPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodCallHandler,
    EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var activity: Activity? = null
    private var secureModeEnabled = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "setSecureMode" -> {
                val enabled = call.argument<Boolean>("enabled")
                if (enabled == null) {
                    result.error("invalid_arguments", "'enabled' must be a bool", null)
                    return
                }
                setSecureMode(enabled)
                result.success(null)
            }
            // Recording detection needs API 35 (addScreenRecordingCallback); not implemented yet.
            "isScreenCaptured" -> result.success(false)
            else -> result.notImplemented()
        }
    }

    // No Android events yet (screenshot/recording callbacks need API 34/35). The handler is
    // registered so listening from Dart doesn't fail.
    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) = Unit

    override fun onCancel(arguments: Any?) = Unit

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

    private fun setSecureMode(enabled: Boolean) {
        secureModeEnabled = enabled
        applySecureFlag()
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

    private companion object {
        const val METHOD_CHANNEL = "ipr_screen_blur/methods"
        const val EVENT_CHANNEL = "ipr_screen_blur/events"
    }
}
