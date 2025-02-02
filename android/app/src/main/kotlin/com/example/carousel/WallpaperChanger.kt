package com.example.carousel

import android.annotation.TargetApi
import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Log
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
object WallpaperChanger {
    private val bitmapCache = LruCache<String, Bitmap>(calculateCacheSize())

    private fun calculateCacheSize(): Int {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        return maxMemory / 8 // Use 1/8th of available memory for cache
    }

    fun parsePathsFromJson(jsonString: String): List<String> {
        return try {
            val jsonArray = JSONArray(jsonString)
            List(jsonArray.length()) { jsonArray.getString(it) }
        } catch (e: Exception) {
            e.printStackTrace()
            emptyList()
        }
    }

    /**
     * Sets the wallpaper instantly from a preloaded bitmap or decodes a new one.
     */
    @TargetApi(24)
    suspend fun setBitmapAsWallpaper(context: Context, filePath: String) {
        withContext(Dispatchers.IO) {
            try {
                val wallpaperManager = WallpaperManager.getInstance(context)

                // Get device screen size
                val displayMetrics = context.resources.displayMetrics
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels

                // Retrieve cached image or decode a new one
                val originalBitmap = getCachedBitmap(filePath) ?: decodeBitmap(filePath)
                if (originalBitmap == null) {
                    Log.e("WallpaperChanger", "Failed to decode image.")
                    return@withContext
                }

                // Adjust image to fit screen without cropping
                val adjustedBitmap = fitBitmapToScreen(originalBitmap, screenWidth, screenHeight)

                // Apply wallpaper instantly
                wallpaperManager.setBitmap(adjustedBitmap, null, true, WallpaperManager.FLAG_LOCK)

                Log.d("WallpaperChanger", "Wallpaper applied successfully")
            } catch (e: Exception) {
                Log.e("WallpaperChanger", "Error setting wallpaper: ${e.message}")
            }
        }
    }

    /**
     * Decodes an image from file and caches it.
     */
    fun decodeBitmap(filePath: String): Bitmap? {
        return try {
            val options = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888 // High quality
            }
            val bitmap = BitmapFactory.decodeFile(filePath, options)
            bitmap?.also { bitmapCache.put(filePath, it) }
        } catch (e: Exception) {
            Log.e("WallpaperChanger", "Error decoding bitmap: ${e.message}")
            null
        }
    }

    /**
     * Retrieves a cached image.
     */
    private fun getCachedBitmap(filePath: String): Bitmap? {
        return bitmapCache.get(filePath)
    }

    /**
     * Scales the bitmap to fit the screen without cropping or stretching.
     */
    private fun fitBitmapToScreen(original: Bitmap, targetWidth: Int, targetHeight: Int): Bitmap {
        val originalWidth = original.width
        val originalHeight = original.height

        val scaleX = targetWidth.toFloat() / originalWidth
        val scaleY = targetHeight.toFloat() / originalHeight
        val scaleFactor =
            minOf(scaleX, scaleY) * 0.75f // Reduce zoom slightly // Scale to fit without cropping

        val newWidth = (originalWidth * scaleFactor).toInt()
        val newHeight = (originalHeight * scaleFactor).toInt()

        return Bitmap.createScaledBitmap(original, newWidth, newHeight, true)
    }
}
