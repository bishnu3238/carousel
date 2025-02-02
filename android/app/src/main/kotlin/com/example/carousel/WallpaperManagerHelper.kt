package com.example.carousel

import android.annotation.TargetApi
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
class WallpaperManagerHelper(private val context: Context) {
    private val wallpaperPaths = mutableListOf<String>()
    private val wallpaperCache: LruCache<Int, Bitmap>
    private var currentIndex: Int
    private var isRandom = true

    companion object {
        private const val MAX_CACHE_SIZE = 10
        private const val MIN_CACHE_THRESHOLD = 5
    }

    init {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        val cacheSize = maxMemory / 8
        wallpaperCache = LruCache(cacheSize.coerceAtLeast(10 * 1024)) // Minimum size of 10MB
        val sharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        currentIndex = sharedPreferences.getInt("currentIndex", 0)
        loadWallpapersFromPreferences()
        preloadWallpapers()
    }

    fun updateConfiguration(isRandom: Boolean) {
        this.isRandom = isRandom
        loadWallpapersFromPreferences()
        preloadWallpapers()
    }

    suspend fun changeWallpaper() {
        withContext(Dispatchers.IO) {
            if (wallpaperPaths.isEmpty()) return@withContext

            val filePath = wallpaperPaths.getOrNull(currentIndex) ?: return@withContext
            if (!File(filePath).exists()) return@withContext

            WallpaperChanger.setBitmapAsWallpaper(context, filePath)

            currentIndex = calculateNextIndex()
            saveCurrentIndex()

            if (wallpaperCache.size() < MIN_CACHE_THRESHOLD) {
                preloadWallpapers()
            }
        }
    }

    private fun calculateNextIndex(): Int {
        return if (isRandom) {
            val newIndex = (wallpaperPaths.indices).random()
            if (newIndex == currentIndex) calculateNextIndex() else newIndex
        } else {
            (currentIndex + 1) % wallpaperPaths.size
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

    private fun preloadWallpapers() {
        if (wallpaperPaths.isEmpty()) return

        val existingCacheSize = wallpaperCache.size()
        val toPreload = MAX_CACHE_SIZE - existingCacheSize

        if (toPreload > 0) {
            wallpaperPaths.shuffled().take(toPreload).forEachIndexed { index, path ->
                if (!wallpaperCache.snapshot().containsKey(index)) {
                    val bitmap = WallpaperChanger.decodeBitmap(path)
                    if (bitmap != null) {
                        wallpaperCache.put(index, bitmap)
                    }
                }
            }
        }
    }
}
