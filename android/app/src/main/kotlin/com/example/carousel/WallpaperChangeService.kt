package com.example.carousel

//import WallpaperChanger
import android.annotation.TargetApi
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.*

class WallpaperChangeService : Service() {
    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val TAG = "WallpaperChangeService"

    private val wallpaperPaths = mutableListOf<String>()
    private var currentIndex = 0
    private var currentBitmap: Bitmap? = null
    private var nextBitmap: Bitmap? = null
    private var isRandom = true // Default value for `isRandom`
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var preferencesListener: SharedPreferences.OnSharedPreferenceChangeListener


    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        isRandom = sharedPreferences.getBoolean("flutter.lock_screen_random", true)
        loadWallpapersFromPreferences()


        preferencesListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
            when (key) {
                "flutter.lock_screen_random" -> {
                    isRandom = sharedPreferences.getBoolean(key, true)
                    Log.d(TAG, "isRandom updated: $isRandom")
                }

                "flutter.lock_screen_wallpapers" -> {
                    loadWallpapersFromPreferences()
                    Log.d(TAG, "Wallpapers updated dynamically: $wallpaperPaths")
                }
            }
        }

        sharedPreferences.registerOnSharedPreferenceChangeListener(preferencesListener)

        startForeground(1, NotificationHelper.createForegroundNotification(this))
        preloadWallpapers()
    }

    override fun onDestroy() {
        unregisterReceiver(wallpaperChangeReceiver)
        sharedPreferences.unregisterOnSharedPreferenceChangeListener(preferencesListener)

        super.onDestroy()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRandom = intent?.getBooleanExtra("isRandom", true) ?: true

        registerReceiver()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun loadWallpapersFromPreferences() {
        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"
        wallpaperPaths.clear()
        wallpaperPaths.addAll(WallpaperChanger.parsePathsFromJson(jsonString))
        Log.d(TAG, "Loaded wallpapers: $wallpaperPaths")
    }

    private fun preloadWallpapers() {
//        val sharedPreferences =
//            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"
//        wallpaperPaths.clear()
//        wallpaperPaths.addAll(WallpaperChanger.parsePathsFromJson(jsonString))

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
        try {
            if (currentBitmap == null) {
                Log.e(TAG, "No current wallpaper loaded, setting default wallpaper")
                setDefaultWallpaper()
                return
            }

            WallpaperChanger.setBitmapAsWallpaper(this, currentBitmap!!)
            Log.d(TAG, "Wallpaper changed successfully, isRandom: $isRandom")

            if (wallpaperPaths.isEmpty()) {
                Log.e(TAG, "No wallpapers available")
                return
            }

            // Update the current and next wallpaper based on the `isRandom` flag

            if (isRandom) {
                // Pick a random wallpaper
                currentIndex = (wallpaperPaths.indices).random()
                currentBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[currentIndex])

            } else {
                currentIndex = (currentIndex + 1) % wallpaperPaths.size
                currentBitmap = nextBitmap

                val nextIndex = (currentIndex + 1) % wallpaperPaths.size
                nextBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[nextIndex])
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error changing wallpaper: ${e.message}")
        }
    }

    private suspend fun setDefaultWallpaper() {
        withContext(Dispatchers.IO) {
            try {
                val defaultWallpaper = BitmapFactory.decodeResource(
                    resources, R.drawable.default_wallpaper
                )
                WallpaperChanger.setBitmapAsWallpaper(this@WallpaperChangeService, defaultWallpaper)
                Log.d(TAG, "Default wallpaper set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting default wallpaper: ${e.message}")
            }
        }
    }
}
