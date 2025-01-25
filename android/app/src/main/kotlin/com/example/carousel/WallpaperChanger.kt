package com.example.carousel


import android.annotation.TargetApi
import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray

object WallpaperChanger {
    private const val TAG = "WallpaperChanger"

    /**
     * Parse wallpaper paths from a JSON string.
     */
    fun parsePathsFromJson(jsonString: String): List<String> {
        return try {
            val jsonArray = JSONArray(jsonString)
            List(jsonArray.length()) { jsonArray.getString(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing JSON: ${e.message}")
            emptyList()
        }
    }

    /**
     * Set a bitmap as the lock screen wallpaper, ensuring it fits the screen dimensions perfectly.
     * This runs in a background thread to avoid blocking the main thread.
     */
    @TargetApi(Build.VERSION_CODES.ECLAIR)
    suspend fun setBitmapAsWallpaper(context: Context, bitmap: Bitmap) {
        withContext(Dispatchers.IO) {
            try {
                val wallpaperManager = WallpaperManager.getInstance(context)
                val screenBitmap = resizeBitmapToFitScreen(context, bitmap)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(screenBitmap, null, true, WallpaperManager.FLAG_LOCK)
                }
                Log.d(TAG, "Wallpaper set successfully with adjusted resolution")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting wallpaper: ${e.message}")
            }
        }
    }

    /**
     * Resize and crop the bitmap to fit the screen's dimensions without distortion.
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private fun resizeBitmapToFitScreen(context: Context, bitmap: Bitmap): Bitmap {
        // Get screen dimensions
        val displayMetrics = DisplayMetrics()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getRealMetrics(displayMetrics)
        val screenWidth = displayMetrics.widthPixels
        val screenHeight = displayMetrics.heightPixels

        Log.d(TAG, "Screen dimensions: width=$screenWidth, height=$screenHeight")
        Log.d(TAG, "Original bitmap dimensions: width=${bitmap.width}, height=${bitmap.height}")

        // Calculate aspect ratio
        val bitmapRatio = bitmap.width.toFloat() / bitmap.height
        val screenRatio = screenWidth.toFloat() / screenHeight

        // Scale the bitmap to fit the screen
        val scaledWidth: Int
        val scaledHeight: Int
        if (bitmapRatio > screenRatio) {
            // Wider image: Scale to match height, crop width
            scaledHeight = screenHeight
            scaledWidth = (bitmapRatio * screenHeight).toInt()
        } else {
            // Taller image: Scale to match width, crop height
            scaledWidth = screenWidth
            scaledHeight = (screenWidth / bitmapRatio).toInt()
        }

        // Create a scaled bitmap
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true)

        // Crop the center portion of the scaled bitmap to fit the screen
        val xOffset = (scaledBitmap.width - screenWidth) / 2
        val yOffset = (scaledBitmap.height - screenHeight) / 2

        Log.d(
            TAG,
            "Scaled bitmap dimensions: width=${scaledBitmap.width}, height=${scaledBitmap.height}"
        )
        Log.d(TAG, "Cropping to: xOffset=$xOffset, yOffset=$yOffset")

        return Bitmap.createBitmap(scaledBitmap, xOffset, yOffset, screenWidth, screenHeight)
    }

    /**
     * Decode a bitmap from a file with the highest quality configuration.
     */
    suspend fun decodeBitmap(filePath: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
                    inPreferredConfig = Bitmap.Config.ARGB_8888 // High quality
                })
            } catch (e: Exception) {
                Log.e(TAG, "Error decoding bitmap: ${e.message}")
                null
            }
        }
    }
}
