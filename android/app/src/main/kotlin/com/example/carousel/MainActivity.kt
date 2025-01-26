package com.example.carousel

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.carousel/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockScreenWallpaperChange" -> {
                    val isRandom = call.argument<Boolean>("isRandom") ?: true
                    startLockScreenWallpaperChange(isRandom)
                    result.success("Wallpaper change started")
                }

                "stopLockScreenWallpaperChange" -> {
                    stopLockScreenWallpaperChange()
                    result.success("Wallpaper change stopped")
                }

                "requestBatteryOptimizationExemption" -> {
                    requestBatteryOptimizationExemption(result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startLockScreenWallpaperChange(isRandom: Boolean) {
        val serviceIntent = Intent(this, WallpaperChangeService::class.java).apply {
            putExtra("isRandom", isRandom)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ContextCompat.startForegroundService(this, serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopLockScreenWallpaperChange() {
        val serviceIntent = Intent(this, WallpaperChangeService::class.java)
        stopService(serviceIntent)
    }

    private fun requestBatteryOptimizationExemption(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    val intent =
                        Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = android.net.Uri.parse("package:$packageName")
                        }
                    startActivity(intent)
                    result.success("Battery optimization exemption requested")
                } catch (e: Exception) {
                    result.error(
                        "EXEMPTION_ERROR",
                        "Failed to request battery optimization exemption",
                        e.localizedMessage
                    )
                }
            } else {
                result.success("Already exempt from battery optimization")
            }
        } else {
            result.error(
                "NOT_SUPPORTED",
                "Battery optimization exemption not supported on this Android version",
                null
            )
        }
    }
}
