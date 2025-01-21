package com.example.carousel

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import java.io.File

class ChangeWallpaperWorker(context: Context, workerParams: WorkerParameters) :
    Worker(context, workerParams) {
    private val TAG = "ChangeWallpaperWorker"
    companion object {
        private var currentIndex = 0
    }

    override fun doWork(): Result {
        return try {
            val isRandom = inputData.getBoolean("isRandom", true)
            Log.d(TAG, "doWork with random: $isRandom")
            val wallpaperPaths = getWallpaperPaths("flutter.lock_screen_wallpapers")
            Log.d(TAG, "Wallpaper paths: $wallpaperPaths")
            if (wallpaperPaths.isEmpty()) {
                Log.e(TAG, "No wallpapers found")
                return Result.failure()
            }

            val selectedWallpaper = if (isRandom) {
                wallpaperPaths.random()
            } else {
                val wallpaper = wallpaperPaths[currentIndex]
                currentIndex = (currentIndex + 1) % wallpaperPaths.size
                Log.d(TAG, "Selected wallpaper by index: $currentIndex and path is: $wallpaper")
                wallpaper
            }

            setWallpaper(selectedWallpaper)
            Log.d(TAG, "Wallpaper change task is successful image path: $selectedWallpaper")
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error changing wallpaper: ${e.message}")
            Result.failure()
        }
    }
 
    private fun getWallpaperPaths(key: String): List<String> {
        val sharedPreferences = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString(key, "[]") ?: "[]"

        Log.d(TAG, "SharedPreferences JSON String: $jsonString")

        return try {
            val jsonArray = JSONArray(jsonString)
            val paths = mutableListOf<String>()
            for (i in 0 until jsonArray.length()) {
                paths.add(jsonArray.getString(i))
            }
            Log.d(TAG, "Parsed paths: $paths")
            paths
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing JSON string: ${e.message}")
            emptyList()
        }
    }

    private fun setWallpaper(path: String) {
        val file = File(path)
        if (!file.exists()) {
            Log.e(TAG, "File does not exist: $path")
            return
        }

        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
        val wallpaperManager = WallpaperManager.getInstance(applicationContext)
        wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
        Log.d(TAG, "Wallpaper changed successfully")
    }
}