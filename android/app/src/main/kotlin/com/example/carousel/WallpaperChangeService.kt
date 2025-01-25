package com.example.carousel


import android.annotation.TargetApi
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.os.Build
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class WallpaperChangeService : Service() {
    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val TAG = "WallpaperChangeService"

    private val wallpaperPaths = mutableListOf<String>()
    private var currentIndex = 0
    private var currentBitmap: Bitmap? = null
    private var nextBitmap: Bitmap? = null

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        startForeground(1, NotificationHelper.createForegroundNotification(this))
        preloadWallpapers()
    }

    override fun onDestroy() {
        unregisterReceiver(wallpaperChangeReceiver)
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        registerReceiver()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun preloadWallpapers() {
        // Load wallpaper paths from shared preferences
        val sharedPreferences =
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"
        wallpaperPaths.clear()
        wallpaperPaths.addAll(WallpaperChanger.parsePathsFromJson(jsonString))

        if (wallpaperPaths.isNotEmpty()) {
            GlobalScope.launch {
                currentBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[currentIndex])
                val nextIndex = (currentIndex + 1) % wallpaperPaths.size
                nextBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[nextIndex])
            }
        }
    }

    private fun registerReceiver() {
        wallpaperChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_ON) {
                    GlobalScope.launch { changeWallpaper() }
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(wallpaperChangeReceiver, filter)
    }

    private suspend fun changeWallpaper() {
        if (currentBitmap == null) {
            Log.e(TAG, "No current wallpaper loaded")
            return
        }

        WallpaperChanger.setBitmapAsWallpaper(this, currentBitmap!!)
        currentIndex = (currentIndex + 1) % wallpaperPaths.size
        currentBitmap = nextBitmap

        val nextIndex = (currentIndex + 1) % wallpaperPaths.size
        nextBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[nextIndex])
    }
}
