package com.itp.ezybill.ezybill

import android.annotation.SuppressLint
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Device identity for BMS registration / login `imei`.
    // Mirrors the native EzyBill app on API 29+ (Settings.Secure.ANDROID_ID):
    // stable per device + app signing key + user, survives reinstall, needs
    // no runtime permission. The legacy TelephonyManager.getDeviceId() path is
    // intentionally not replicated (requires READ_PHONE_STATE, removed on 10+).
    private val deviceChannel = "com.itp.ezybill/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "androidId" -> result.success(androidId())
                    else -> result.notImplemented()
                }
            }
    }

    @SuppressLint("HardwareIds")
    private fun androidId(): String {
        return try {
            Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: ""
        } catch (e: Exception) {
            // Dart treats an empty value as "unavailable" and keeps its fallback.
            ""
        }
    }
}
