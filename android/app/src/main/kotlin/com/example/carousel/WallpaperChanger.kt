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

    fun parsePathsFromJson(jsonString: String): List<String> {
        return try {
            val jsonArray = JSONArray(jsonString)
            List(jsonArray.length()) { jsonArray.getString(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing JSON: ${e.message}")
            emptyList()
        }
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    suspend fun setBitmapAsWallpaper(context: Context, bitmap: Bitmap) {
        withContext(Dispatchers.IO) {
            try {
                val wallpaperManager = WallpaperManager.getInstance(context)
                val resizedBitmap = resizeBitmapToFitScreen(context, bitmap)
                wallpaperManager.setBitmap(resizedBitmap, null, true, WallpaperManager.FLAG_LOCK)
                Log.d(TAG, "Wallpaper set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting wallpaper: ${e.message}")
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private fun resizeBitmapToFitScreen(context: Context, bitmap: Bitmap): Bitmap {
        val displayMetrics = DisplayMetrics()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getRealMetrics(displayMetrics)
        val screenWidth = displayMetrics.widthPixels
        val screenHeight = displayMetrics.heightPixels

        val bitmapRatio = bitmap.width.toFloat() / bitmap.height
        val screenRatio = screenWidth.toFloat() / screenHeight

        val scaledWidth: Int
        val scaledHeight: Int
        if (bitmapRatio > screenRatio) {
            scaledHeight = screenHeight
            scaledWidth = (bitmapRatio * screenHeight).toInt()
        } else {
            scaledWidth = screenWidth
            scaledHeight = (screenWidth / bitmapRatio).toInt()
        }

        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true)
        val xOffset = (scaledBitmap.width - screenWidth) / 2
        val yOffset = (scaledBitmap.height - screenHeight) / 2
        return Bitmap.createBitmap(scaledBitmap, xOffset, yOffset, screenWidth, screenHeight)
    }

    suspend fun decodeBitmap(filePath: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                })
            } catch (e: Exception) {
                Log.e(TAG, "Error decoding bitmap: ${e.message}")
                null
            }
        }
    }
}
