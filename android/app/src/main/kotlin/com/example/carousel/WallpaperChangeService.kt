package com.example.carousel

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.IBinder
import android.util.Log
import java.io.File

class WallpaperChangeService : Service() {

    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val TAG = "WallpaperChangeService"

    private val wallpaperPaths = mutableListOf<String>()
    private val wallpaperBitmaps = mutableListOf<Bitmap>()
    private var currentIndex = 0

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate called")
        startForeground(1, NotificationHelper.createForegroundNotification(this))
        preloadWallpapers() // Preload wallpapers when the service starts
    }

    override fun onDestroy() {
        Log.d(TAG, "Service onDestroy called")
        unregisterReceiver(wallpaperChangeReceiver)
        wallpaperChangeReceiver = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val isRandom = intent?.getBooleanExtra("isRandom", true) ?: true
        Log.d(TAG, "Service onStartCommand called with isRandom = $isRandom")
        registerReceiver(isRandom)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun preloadWallpapers() {
        Log.d(TAG, "Preloading wallpapers")
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"

        wallpaperPaths.clear()
        wallpaperBitmaps.clear()

        try {
            val paths = WallpaperChanger.parsePathsFromJson(jsonString)
            if (paths.isEmpty()) {
                Log.e(TAG, "No valid paths found in JSON")
                return
            }

            for (path in paths) {
                val file = File(path)
                if (file.exists()) {
                    wallpaperPaths.add(path) // Add path to the list
                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                    if (bitmap != null) {
                        wallpaperBitmaps.add(bitmap) // Add decoded bitmap to the list
                    } else {
                        Log.e(TAG, "Failed to decode bitmap for path: $path")
                    }
                } else {
                    Log.e(TAG, "File does not exist: $path")
                }
            }

            Log.d(TAG, "Preloaded ${wallpaperPaths.size} wallpaper paths and ${wallpaperBitmaps.size} bitmaps")
        } catch (e: Exception) {
            Log.e(TAG, "Error preloading wallpapers: ${e.message}")
        }
    }

    private fun registerReceiver(isRandom: Boolean) {
        Log.d(TAG, "registerReceiver called")
        wallpaperChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d(TAG, "Intent received: ${intent?.action}")
                if (intent?.action == Intent.ACTION_SCREEN_ON) {
                    Log.d(TAG, "Screen is on intent")
                    changeWallpaper(isRandom)
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(wallpaperChangeReceiver, filter)
        Log.d(TAG, "receiver registered")
    }

    private fun changeWallpaper(isRandom: Boolean) {
        if (wallpaperBitmaps.isEmpty()) {
            Log.e(TAG, "No wallpapers preloaded")
            return
        }

        val selectedBitmap = if (isRandom) {
            wallpaperBitmaps.random()
        } else {
            val bitmap = wallpaperBitmaps[currentIndex]
            currentIndex = (currentIndex + 1) % wallpaperBitmaps.size
            bitmap
        }

        WallpaperChanger.setBitmapAsWallpaper(this, selectedBitmap)
    }
}
