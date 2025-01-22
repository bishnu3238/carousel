package com.example.carousel

import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import org.json.JSONArray

object WallpaperChanger {

    private const val TAG = "WallpaperChanger"

    fun parsePathsFromJson(jsonString: String): List<String> {
        return try {
            val jsonArray = JSONArray(jsonString)
            val paths = mutableListOf<String>()
            for (i in 0 until jsonArray.length()) {
                paths.add(jsonArray.getString(i))
            }
            paths
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing JSON string: ${e.message}")
            emptyList()
        }
    }

    fun setBitmapAsWallpaper(context: Context, bitmap: Bitmap) {
        try {
            val wallpaperManager = WallpaperManager.getInstance(context)
            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
            Log.d(TAG, "Wallpaper set successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting wallpaper: ${e.message}")
        }
    }
}
