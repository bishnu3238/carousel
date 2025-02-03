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
        Log.d("WallpaperChanger", "Setting wallpaper: $filePath")
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
        Log.d("WallpaperChanger", "Original size: $originalWidth x $originalHeight")

        Log.d("WallpaperChanger", "Target size: $targetWidth x $targetHeight")

        val aspectRationScreen = targetWidth.toFloat() / targetHeight
        val aspectRatioImage = originalWidth.toFloat() / originalHeight
        Log.d(
            "WallpaperChanger",
            "Aspect ratio screen: $aspectRationScreen, Aspect ratio image: $aspectRatioImage"
        )

        return if (aspectRatioImage > aspectRationScreen) {
            // Image is wider than screen -> Crop width
            Log.d("WallpaperChanger", "Image is wider than screen")
            val scaledHeight = targetHeight
            val scaledWidth = (scaledHeight * aspectRatioImage).toInt()
            val resizedBitmap = Bitmap.createScaledBitmap(original, scaledWidth, scaledHeight, true)
            Log.d("WallpaperChanger", "Scaled width: $scaledWidth, Scaled height: $scaledHeight")

            // Crop to match BoxFit.cover behavior
            val xOffset = (scaledWidth - targetWidth) / 2
            Log.d("WallpaperChanger", "X offset: $xOffset")
            Bitmap.createBitmap(resizedBitmap, xOffset, 0, targetWidth, targetHeight)
        } else {
            // Image is taller than screen -> Crop height
            Log.d("WallpaperChanger", "Image is taller than screen")
            val scaledWidth = targetWidth
            val scaledHeight = (scaledWidth / aspectRatioImage).toInt()
            val resizedBitmap = Bitmap.createScaledBitmap(original, scaledWidth, scaledHeight, true)
            Log.d("WallpaperChanger", "Scaled width: $scaledWidth, Scaled height: $scaledHeight")

            // Crop to match BoxFit.cover behavior
            val yOffset = (scaledHeight - targetHeight) / 2
            Log.d("WallpaperChanger", "Y offset: $yOffset")
            Bitmap.createBitmap(resizedBitmap, 0, yOffset, targetWidth, targetHeight)
        }
    }

//    private fun fitBitmapToScreen(original: Bitmap, targetWidth: Int, targetHeight: Int): Bitmap {
//        val originalWidth = original.width
//        val originalHeight = original.height
//        Log.d("WallpaperChanger", "Original size: $originalWidth x $originalHeight")
//
//        val scaleX = targetWidth.toFloat() / originalWidth
//        val scaleY = targetHeight.toFloat() / originalHeight
//        Log.d("WallpaperChanger", "Scale X: $scaleX, Scale Y: $scaleY")
//
//        val scaleFactor =
//            minOf(scaleX, scaleY) * 0.95f // Reduce zoom slightly // Scale to fit without cropping
//
//        Log.d("WallpaperChanger", "Scale factor: $scaleFactor")
//        val newWidth = (originalWidth * scaleFactor).toInt()
//        val newHeight = (originalHeight * scaleFactor).toInt()
//
//        Log.d("WallpaperChanger", "New size: $newWidth x $newHeight")
//        return Bitmap.createScaledBitmap(original, newWidth, newHeight, true)
//    }
}
//D/WallpaperChanger(25686): Setting wallpaper: /data/user/0/com.example.carousel/cache/18148993-a52a-4ff2-9653-750759f854f3/db8039a124988afc136c6941c6939c8d.jpg
//D/WallpaperChanger(25686): Original size: 736 x 1308
//D/WallpaperChanger(25686): Scale X: 1.4673913, Scale Y: 1.7889909
//D/WallpaperChanger(25686): Scale factor: 0.3668478
//D/WallpaperChanger(25686): New size: 270 x 479
//D/WallpaperChanger(25686): Wallpaper applied successfully
//D/WallpaperChanger(25686): Setting wallpaper: /data/user/0/com.example.carousel/cache/e380ce79-d99c-4654-b277-75402999e9b5/d14de468f1954006050b7d8cfeb4be3b.jpg
//D/WallpaperChanger(25686): Original size: 735 x 1045
//D/WallpaperChanger(25686): Scale X: 1.4693878, Scale Y: 2.2392344
//D/WallpaperChanger(25686): Scale factor: 0.36734694
//D/WallpaperChanger(25686): New size: 270 x 383
//D/WallpaperChanger(25686): Wallpaper applied successfully
//D/WallpaperChanger(25686): Setting wallpaper: /data/user/0/com.example.carousel/cache/03e256b7-98a1-44d9-bfe5-fd139613c485/e539854198aa129969458a40fb94c0e1.jpg
//D/WallpaperChanger(25686): Original size: 736 x 1308
//D/WallpaperChanger(25686): Scale X: 1.4673913, Scale Y: 1.7889909
//D/WallpaperChanger(25686): Scale factor: 0.3668478
//D/WallpaperChanger(25686): New size: 270 x 479
//D/WallpaperChanger(25686): Wallpaper applied successfully