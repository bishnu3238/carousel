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

//    suspend fun decodeBitmap(filePath: String): Bitmap? {
//        return withContext(Dispatchers.IO) {
//            try {
//                BitmapFactory.decodeFile(filePath, BitmapFactory.Options().apply {
//                    inPreferredConfig = Bitmap.Config.ARGB_8888
//                    inSampleSize = calculateSampleSize(filePath)
//                })
//            } catch (e: Exception) {
//                e.printStackTrace()
//                null
//            }
//        }
//    }
//
//    private fun calculateSampleSize(filePath: String): Int {
//        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
//        BitmapFactory.decodeFile(filePath, options)
//        val (width, height) = options.outWidth to options.outHeight
//        val targetWidth = 1080
//        val targetHeight = 1920
//        var sampleSize = 1
//
//        while (width / sampleSize > targetWidth || height / sampleSize > targetHeight) {
//            sampleSize *= 2
//        }
//        return sampleSize
//    }


    suspend fun decodeBitmap(
        filePath: String,
        reqWidth: Int,
        reqHeight: Int
    ): Bitmap? = withContext(Dispatchers.IO) {
        try {
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFile(filePath, options)

            options.inSampleSize = calculateSampleSize(
                width = options.outWidth,
                height = options.outHeight,
                reqWidth = reqWidth,
                reqHeight = reqHeight
            )

            options.inJustDecodeBounds = false
            options.inPreferredConfig = Bitmap.Config.ARGB_8888 // More memory efficient

            val bitmap = BitmapFactory.decodeFile(filePath, options)
            bitmap?.let { scaleBitmapToFitScreen(it, reqWidth, reqHeight) }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun calculateSampleSize(
        width: Int,
        height: Int,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        var sampleSize = 1

        val halfWidth = width / 2
        val halfHeight = height / 2

        while (halfWidth / sampleSize >= reqWidth &&
            halfHeight / sampleSize >= reqHeight
        ) {
            sampleSize *= 2
        }

        return sampleSize
    }


    private fun scaleBitmapToFitScreen(
        bitmap: Bitmap,
        screenWidth: Int,
        screenHeight: Int
    ): Bitmap {
        val aspectRatio = bitmap.width.toFloat() / bitmap.height.toFloat()
        val targetWidth: Int
        val targetHeight: Int

        if (bitmap.width > bitmap.height) {
            // Landscape Image
            targetWidth = screenWidth
            targetHeight = (screenWidth / aspectRatio).toInt()
        } else {
            // Portrait Image
            targetHeight = screenHeight
            targetWidth = (screenHeight * aspectRatio).toInt()
        }

        return Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
    }
}