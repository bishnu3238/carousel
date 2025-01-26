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
import android.util.LruCache
import kotlinx.coroutines.*

class WallpaperChangeService : Service() {
    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private lateinit var wallpaperCache: LruCache<Int, Bitmap>

    private val wallpaperPaths = mutableListOf<String>()
    private var currentIndex = 0
    private var isRandom = true

    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
    override fun onCreate() {
        super.onCreate()

        // Initialize LruCache for preloading wallpapers
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        val cacheSize = calculateOptimalCacheSize(maxMemory)
        wallpaperCache = LruCache(cacheSize)

        loadWallpapersFromPreferences()
        preloadWallpapersInCache()
        startForeground(1, NotificationHelper.createForegroundNotification(this))
    }

    override fun onDestroy() {
        unregisterReceiver(wallpaperChangeReceiver)
        serviceScope.cancel()
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
        val sharedPreferences =
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"
        wallpaperPaths.clear()
        wallpaperPaths.addAll(WallpaperChanger.parsePathsFromJson(jsonString))
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
    private fun preloadWallpapersInCache() {
        serviceScope.launch(Dispatchers.IO) {
            for (i in wallpaperPaths.indices) {
                try {
                    if (wallpaperCache.get(i) == null) {
                        wallpaperCache.put(
                            i,
                            WallpaperChanger.decodeBitmap(wallpaperPaths[i]) ?: continue
                        )
                    }
                } catch (e: OutOfMemoryError) {
                    e.printStackTrace()
                    wallpaperCache.evictAll() // Clear cache to recover memory
                }
            }
        }
    }

    private fun registerReceiver() {
        if (wallpaperChangeReceiver == null) {
            wallpaperChangeReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == Intent.ACTION_SCREEN_ON) {
                        serviceScope.launch { changeWallpaper() }
                    }
                }
            }
            val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
            registerReceiver(wallpaperChangeReceiver, filter)
        }
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
    private suspend fun changeWallpaper() {
        try {
            if (wallpaperPaths.isEmpty()) {
                // Log a warning when no wallpapers are available
                println("Warning: No wallpapers available to set.")
                return
            }

            val bitmap = wallpaperCache.get(currentIndex) ?: run {
                // Decode and cache if not already in memory
                val decodedBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[currentIndex])
                if (decodedBitmap != null) {
                    wallpaperCache.put(currentIndex, decodedBitmap)
                }
                decodedBitmap
            } ?: return

            WallpaperChanger.setBitmapAsWallpaper(this, bitmap)

            // Prepare next wallpaper in advance
            val nextIndex = if (isRandom) {
                if (wallpaperPaths.size > 1) {
                    generateSequence { (wallpaperPaths.indices).random() }.first { it != currentIndex }
                } else {
                    currentIndex
                }
            } else {
                (currentIndex + 1) % wallpaperPaths.size
            }

            if (wallpaperCache.get(nextIndex) == null) {
                try {
                    wallpaperCache.put(
                        nextIndex,
                        WallpaperChanger.decodeBitmap(wallpaperPaths[nextIndex]) ?: return
                    )
                } catch (e: OutOfMemoryError) {
                    e.printStackTrace()
                    wallpaperCache.evictAll() // Clear cache to recover memory
                }
            }

            currentIndex = nextIndex
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun calculateOptimalCacheSize(maxMemory: Int): Int {
        // Adjust cache size to ensure better memory handling
        return when {
            maxMemory < 16 * 1024 -> maxMemory / 8 // Low memory devices
            maxMemory < 64 * 1024 -> maxMemory / 6 // Mid-range devices
            else -> maxMemory / 4 // High-end devices
        }
    }
}