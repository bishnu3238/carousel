package com.example.carousel

import android.annotation.TargetApi
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.util.DisplayMetrics
import android.util.LruCache
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
class WallpaperManagerHelper(private val context: Context) {
    private val wallpaperPaths = mutableListOf<String>()
    private val wallpaperCache: LruCache<Int, Bitmap>
    private var currentIndex: Int
    private var isRandom = true
    private val displayMetrics: DisplayMetrics by lazy {
        context.resources.displayMetrics
    }

    // Calculate target dimensions based on screen size
    private val targetWidth: Int get() = displayMetrics.widthPixels
    private val targetHeight: Int get() = displayMetrics.heightPixels

    init {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        val cacheSize = maxMemory / 8 // More conservative cache size
        wallpaperCache = object : LruCache<Int, Bitmap>(cacheSize) {
            @TargetApi(Build.VERSION_CODES.KITKAT)
            override fun sizeOf(key: Int, value: Bitmap): Int {
                // Return size in kilobytes
                return value.allocationByteCount / 1024
            }
        }
        val sharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        currentIndex = sharedPreferences.getInt("currentIndex", 0).coerceAtLeast(0)
        loadWallpapersFromPreferences()
        preloadNextWallpaper()
    }

    fun updateConfiguration(isRandom: Boolean) {
        this.isRandom = isRandom
        loadWallpapersFromPreferences()
        preloadNextWallpaper()

    }

    //    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
//    suspend fun changeWallpaper() {
//        withContext(Dispatchers.IO) {
//            if (wallpaperPaths.isEmpty()) return@withContext
//
//            val bitmap = wallpaperCache.get(currentIndex) ?: run {
//                val decodedBitmap = WallpaperChanger.decodeBitmap(wallpaperPaths[currentIndex])
//                    ?: return@withContext
//                wallpaperCache.put(currentIndex, decodedBitmap)
//                decodedBitmap
//            }
//
//            WallpaperChanger.setBitmapAsWallpaper(context, bitmap)
//
//            currentIndex = if (isRandom) {
//                (wallpaperPaths.indices).random()
//            } else {
//                (currentIndex + 1) % wallpaperPaths.size
//            }
//            saveCurrentIndex() // Save the new index
//        }
//    }
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
    suspend fun changeWallpaper() {
        withContext(Dispatchers.IO) {
            if (wallpaperPaths.isEmpty()) return@withContext

            try {
                val bitmap = getCachedOrDecodedBitmap(currentIndex) ?: return@withContext
                WallpaperChanger.setBitmapAsWallpaper(context, bitmap)

                // Update index only after successful set
                currentIndex = calculateNextIndex()
                saveCurrentIndex()
                preloadNextWallpaper()
            } catch (e: Exception) {
                // Handle error and try previous index
                currentIndex = (currentIndex - 1).coerceAtLeast(0)
                saveCurrentIndex()
            }
        }
    }

    private suspend fun getCachedOrDecodedBitmap(index: Int): Bitmap? {
        return wallpaperCache.get(index) ?: run {
            val filePath = wallpaperPaths.getOrNull(index) ?: return@run null
            if (!File(filePath).exists()) return@run null

            WallpaperChanger.decodeBitmap(
                filePath = filePath,
                reqWidth = targetWidth,
                reqHeight = targetHeight
            )?.also { bitmap ->
                wallpaperCache.put(index, bitmap)
            }
        }
    }

    private fun calculateNextIndex(): Int {
        return if (isRandom) {
            (wallpaperPaths.indices).random()
        } else {
            (currentIndex + 1) % wallpaperPaths.size
        }
    }

    fun preloadNextWallpaper() {
        if (wallpaperPaths.isEmpty()) return

        CoroutineScope(Dispatchers.IO).launch {
            val nextIndex = calculateNextIndex()
            if (wallpaperCache.get(nextIndex) != null) {
                getCachedOrDecodedBitmap(nextIndex)
            }
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
        // Ensure index stays within bounds
        currentIndex = currentIndex.coerceIn(0, wallpaperPaths.size - 1)
        saveCurrentIndex()
    }
}