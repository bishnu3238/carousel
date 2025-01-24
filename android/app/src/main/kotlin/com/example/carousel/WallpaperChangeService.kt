package com.example.carousel

import android.annotation.TargetApi
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.util.Log
import java.io.File
import java.util.concurrent.Executors

class WallpaperChangeService : Service() {
    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val TAG = "WallpaperChangeService"

    private val wallpaperPaths = mutableListOf<String>()
    private var currentIndex = 0
    private var lastChangeTime = 0L

    private var currentBitmap: Bitmap? = null
    private var nextBitmap: Bitmap? = null
    private val executor = Executors.newSingleThreadExecutor()

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate called")
        startForeground(1, NotificationHelper.createForegroundNotification(this))
        preloadWallpapers()
    }

    override fun onDestroy() {
        Log.d(TAG, "Service onDestroy called")
        unregisterReceiver(wallpaperChangeReceiver)
        wallpaperChangeReceiver = null
        super.onDestroy()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
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

        try {
            Log.d(TAG, "SharedPreferences JSON String: $jsonString")
            val paths = WallpaperChanger.parsePathsFromJson(jsonString)
            if (paths.isEmpty()) {
                Log.e(TAG, "No valid paths found in JSON")
                return
            }

            for (path in paths) {
                val file = File(path)
                if (file.exists()) {
                    wallpaperPaths.add(path)
                    Log.d(TAG, "Valid wallpaper path: $path")
                } else {
                    Log.e(TAG, "File does not exist: $path")
                }
            }

            if (wallpaperPaths.isNotEmpty()) {
                currentBitmap = decodeBitmap(File(wallpaperPaths[0]))
                preloadNextWallpaper()
                Log.d(TAG, "Preloaded ${wallpaperPaths.size} wallpaper paths")
            } else {
                Log.e(TAG, "No valid wallpapers to preload")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error preloading wallpapers: ${e.message}")
        }
    }

    private fun preloadNextWallpaper() {
        executor.execute {
            val nextIndex = (currentIndex + 1) % wallpaperPaths.size
            nextBitmap = decodeBitmap(File(wallpaperPaths[nextIndex]))
            Log.d(TAG, "Next wallpaper preloaded: $nextIndex")
        }
    }

    private fun registerReceiver(isRandom: Boolean) {
        wallpaperChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_ON) {
                    changeWallpaper(isRandom)
                }
            }
        }
        registerReceiver(wallpaperChangeReceiver, IntentFilter(Intent.ACTION_SCREEN_ON))
        Log.d(TAG, "Receiver registered")
    }

    private fun changeWallpaper(isRandom: Boolean) {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastChangeTime < 10000) { // Minimum 10-second delay
            Log.d(TAG, "Skipping wallpaper change to save battery")
            return
        }

        lastChangeTime = currentTime

        if (currentBitmap == null) {
            Log.e(TAG, "No current wallpaper loaded - Check wallpaper paths or decoding issues")
            return
        }

        WallpaperChanger.setBitmapAsWallpaper(this, currentBitmap!!)
        Log.d(TAG, "Wallpaper set successfully")

        // Move to the next wallpaper
        currentIndex = if (isRandom) {
            (wallpaperPaths.indices).random()
        } else {
            (currentIndex + 1) % wallpaperPaths.size
        }

        currentBitmap = nextBitmap // Use the preloaded bitmap
        preloadNextWallpaper() // Preload the next wallpaper
    }

    private fun decodeBitmap(file: File): Bitmap? {
        return try {
            BitmapFactory.decodeFile(file.absolutePath, BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888 // Highest quality
            })
        } catch (e: Exception) {
            Log.e(TAG, "Error decoding bitmap: ${e.message}")
            null
        }
    }
}
