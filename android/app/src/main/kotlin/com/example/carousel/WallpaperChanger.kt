package com.example.carousel

import android.annotation.TargetApi
import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray

object WallpaperChanger {
    fun parsePathsFromJson(jsonString: String): List<String> {
        return try {
            val jsonArray = JSONArray(jsonString)
            List(jsonArray.length()) { jsonArray.getString(it) }
        } catch (e: Exception) {
            e.printStackTrace()
            emptyList()
        }
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    suspend fun setBitmapAsWallpaper(context: Context, bitmap: Bitmap) {
        withContext(Dispatchers.IO) {
            try {
                val wallpaperManager = WallpaperManager.getInstance(context)
                wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    suspend fun decodeBitmap(filePath: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                    inSampleSize =
                        calculateSampleSize(filePath) // Efficient decoding for large images
                })
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }

    private fun calculateSampleSize(filePath: String): Int {
        // Placeholder implementation for image sample size calculation
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(filePath, options)
        val (width, height) = options.outWidth to options.outHeight
        val targetWidth = 1080
        val targetHeight = 1920
        var sampleSize = 1

        while (width / sampleSize > targetWidth || height / sampleSize > targetHeight) {
            sampleSize *= 2
        }
        return sampleSize
    }
}

//did we not required this code to track changes on sharedpreferances and update changes as soon as enable or wallpaper list change from flutter side =  preferencesListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
//            when (key) {
//                "flutter.lock_screen_random" -> {
//                    isRandom = sharedPreferences.getBoolean(key, true)
//                    Log.d(TAG, "isRandom updated: $isRandom")
//                }
//                "flutter.lock_screen_wallpapers" -> {
//                    loadWallpapersFromPreferences()
//                    Log.d(TAG, "Wallpapers updated dynamically: $wallpaperPaths")
//                }
//            }
//        }
//        sharedPreferences.registerOnSharedPreferenceChangeListener(preferencesListener)