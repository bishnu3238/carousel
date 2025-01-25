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
                    requestBatteryOptimizationExemption()
                    result.success("Battery optimization exemption requested")
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startLockScreenWallpaperChange(isRandom: Boolean) {
        val serviceIntent = Intent(this, WallpaperChangeService::class.java)
        serviceIntent.putExtra("isRandom", isRandom)
        ContextCompat.startForegroundService(this, serviceIntent)
    }

    private fun stopLockScreenWallpaperChange() {
        val serviceIntent = Intent(this, WallpaperChangeService::class.java)
        stopService(serviceIntent)
    }

    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = android.net.Uri.parse("package:$packageName")
                startActivity(intent)
            }
        }
    }
}
