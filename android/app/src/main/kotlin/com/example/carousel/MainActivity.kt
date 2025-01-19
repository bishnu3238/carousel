package com.example.carousel

import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.carousel/wallpaper"
    private var wallpaperChangeService: WallpaperChangeService? = null
    private val FOREGROUND_CHANNEL_ID = "foreground_channel"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "startLockScreenWallpaperChange") {
                startLockScreenWallpaperChange()
                result.success("Wallpaper change started")
            } else if (call.method == "stopLockScreenWallpaperChange") {
                stopLockScreenWallpaperChange()
                result.success("Wallpaper change stopped")
            } else {
                result.notImplemented()
            }
        }
        createNotificationChannel()
    }
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                FOREGROUND_CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startLockScreenWallpaperChange() {
        if (wallpaperChangeService == null) {
            wallpaperChangeService = WallpaperChangeService()
            val serviceIntent = Intent(this, WallpaperChangeService::class.java)
            ContextCompat.startForegroundService(this, serviceIntent)

            Log.d("MainActivity", "Started service for screen on events.")
        }

    }
    private fun stopLockScreenWallpaperChange(){
        if (wallpaperChangeService != null) {
            val serviceIntent = Intent(this, WallpaperChangeService::class.java)
            stopService(serviceIntent)
            wallpaperChangeService = null
            Log.d("MainActivity", "Stopped service for screen on events.")
        }
    }
}