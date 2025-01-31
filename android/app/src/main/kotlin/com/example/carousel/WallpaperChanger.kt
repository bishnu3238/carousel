package com.example.carousel

import android.annotation.TargetApi
import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
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

    @TargetApi(24)
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

    suspend fun decodeBitmap(context: Context, filePath: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(filePath, options)

                val (imageWidth, imageHeight) = options.outWidth to options.outHeight
                val displayMetrics = context.resources.displayMetrics
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels

                val imageAspect = imageWidth.toFloat() / imageHeight
                val screenAspect = screenWidth.toFloat() / screenHeight

                val finalWidth: Int
                val finalHeight: Int

                if (imageAspect > screenAspect) {
                    // Image is wider than screen: adjust width while keeping height
                    finalHeight = screenHeight
                    finalWidth = (screenHeight * imageAspect).toInt()
                } else {
                    // Image is taller than screen: adjust height while keeping width
                    finalWidth = screenWidth
                    finalHeight = (screenWidth / imageAspect).toInt()
                }

                // Decode and scale bitmap
                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                })?.let { originalBitmap ->
                    Bitmap.createScaledBitmap(originalBitmap, finalWidth, finalHeight, true)
                }
                // Ensure the image scales while maintaining aspect ratio
//                val scaleFactor = maxOf(
//                    screenWidth.toFloat() / imageWidth,
//                    screenHeight.toFloat() / imageHeight
//                )
//
//
//                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
//                    inPreferredConfig = Bitmap.Config.ARGB_8888
//                    inSampleSize = calculateSampleSize(filePath)
//                })?.let {
//                    Bitmap.createScaledBitmap(it, finalWidth, finalHeight, true)
//                }
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }

    private fun calculateSampleSize(filePath: String): Int {
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