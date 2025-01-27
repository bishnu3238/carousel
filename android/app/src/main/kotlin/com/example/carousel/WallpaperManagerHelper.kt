package com.example.carousel

import android.annotation.TargetApi
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
class WallpaperManagerHelper(private val context: Context) {
    private val wallpaperPaths = mutableListOf<String>()
    private val wallpaperCache: LruCache<Int, Bitmap>
    private var currentIndex: Int
    private var isRandom = true

    init {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        val cacheSize = maxMemory / 4
        wallpaperCache = LruCache(cacheSize.coerceAtLeast(10 * 1024)) // Minimum size of 10MB
        val sharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        currentIndex = sharedPreferences.getInt("currentIndex", 0) // Load saved index
        loadWallpapersFromPreferences()
    }

    fun updateConfiguration(isRandom: Boolean) {
        this.isRandom = isRandom
        loadWallpapersFromPreferences()
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
    suspend fun changeWallpaper() {
        withContext(Dispatchers.IO) {
            if (wallpaperPaths.isEmpty()) return@withContext

            val bitmap = wallpaperCache.get(currentIndex) ?: run {
                val decodedBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[currentIndex])
                    ?: return@withContext
                wallpaperCache.put(currentIndex, decodedBitmap)
                decodedBitmap
            }

            WallpaperChanger.setBitmapAsWallpaper(context, bitmap)

            currentIndex = if (isRandom) {
                (wallpaperPaths.indices).random()
            } else {
                (currentIndex + 1) % wallpaperPaths.size
            }
            saveCurrentIndex() // Save the new index
        }
    }

    private fun saveCurrentIndex() {
        val sharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        sharedPreferences.edit().putInt("currentIndex", currentIndex).apply()
    }

    fun loadWallpapersFromPreferences() {
        val sharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString("flutter.lock_screen_wallpapers", "[]") ?: "[]"
        wallpaperPaths.clear()
        wallpaperPaths.addAll(WallpaperChanger.parsePathsFromJson(jsonString))
    }
}