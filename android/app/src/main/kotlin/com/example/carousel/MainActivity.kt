package com.example.carousel

import android.content.Intent
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.carousel/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockScreenWallpaperChange" -> {
                    Log.d("MainActivity", "startLockScreenWallpaperChange called from flutter")
                    val isRandom = call.argument<Boolean>("isRandom") ?: true
                    startLockScreenWallpaperChange(isRandom)
                    result.success("Wallpaper change started")
                }
                "stopLockScreenWallpaperChange" -> {
                    Log.d("MainActivity", "stopLockScreenWallpaperChange called from flutter")
                    stopLockScreenWallpaperChange()
                    result.success("Wallpaper change stopped")
                }
                else -> {
                    Log.w("MainActivity", "Method ${call.method} not implemented")
                    result.notImplemented()
                }
            }
        }
    }

    private fun startLockScreenWallpaperChange(isRandom: Boolean) {
        Log.d("MainActivity", "startLockScreenWallpaperChange called, isRandom: $isRandom")
        val serviceIntent = Intent(this, WallpaperChangeService::class.java)
        serviceIntent.putExtra("isRandom", isRandom)
        ContextCompat.startForegroundService(this, serviceIntent)

    }

    private fun stopLockScreenWallpaperChange() {
        Log.d("MainActivity", "stopLockScreenWallpaperChange called")
        val serviceIntent = Intent(this, WallpaperChangeService::class.java)
        stopService(serviceIntent)
    }
}