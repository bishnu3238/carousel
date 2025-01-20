package com.example.carousel

import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.io.File
import java.lang.Exception
import kotlin.random.Random
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import android.graphics.Rect
import com.google.gson.stream.JsonReader
import com.google.gson.JsonSyntaxException

class ChangeWallpaperWorker(appContext: Context, workerParams: WorkerParameters):
    Worker(appContext, workerParams) {

    // `doWork` is the method where actual work happens
    override fun doWork(): Result {
        return try {
            // Call method to change the lock screen wallpaper.
            changeLockScreenWallpaper()
            Log.d("ChangeWallpaperWorker", "Wallpaper change task is successful")

            // If successfully wallpaper has been changed return success.
            Result.success()
        } catch (e: Exception){
            Log.e("ChangeWallpaperWorker", "Failed to set Wallpaper: ${e.message}")
            // If error occurred return failure and log the reason.
            return Result.failure()
        }
    }

    private fun changeLockScreenWallpaper(){
        // getting shared preferences
        val sharedPreferences = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        //  Get lock screen wallpaper paths from shared preferences, and if it is null return an empty list.
        val lockScreenWallpapers =  getStringList("flutter." + "lock_screen_wallpapers")
        // check if list is null or empty
        if(lockScreenWallpapers.isNullOrEmpty()){
            Log.d("ChangeWallpaperWorker", "Wallpaper list is empty")
            return
        }
        // Generate a random number with size of list
        val random = Random.nextInt(lockScreenWallpapers.size);
        // Select the random wallpaper from the list.
        val selectedWallpaper = lockScreenWallpapers[random]
        Log.d("ChangeWallpaperWorker", "Selected wallpaper is $selectedWallpaper")
        try {
            // Get wallpaper manager instance
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            //Decode the selected wallpaper from path to Bitmap.
            val bitmap = BitmapFactory.decodeFile(selectedWallpaper)
            if(bitmap != null){
                val rect = Rect(0,0, bitmap.width, bitmap.height)
                // set bitmap to wallpaper manager, and add a rect, and `FLAG_LOCK` flag to indicate it should be applied on the lock screen.
                wallpaperManager.setBitmap(bitmap,rect, true,  WallpaperManager.FLAG_LOCK )
                Log.d("ChangeWallpaperWorker", "Successfully set wallpaper")

            }else {
                // If could not decode bitmap from path log a error.
                Log.e("ChangeWallpaperWorker", "Failed to decode bitmap from path: $selectedWallpaper")
            }
        }
        catch (e: Exception) {
            // if any exception occurs log it.
            Log.e("ChangeWallpaperWorker", "Exception while set wallpaper from path: $selectedWallpaper exception is: ${e.message}")
        }

    }
    private fun Context.getStringList(key: String): List<String> {
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString(key, null) ?: return emptyList()
        Log.d("ChangeWallpaperWorker", "Json string is $jsonString")
        val reader = JsonReader(jsonString.reader())
        reader.isLenient = true
        return try {
            val type = object : TypeToken<List<String>>() {}.type
            Gson().fromJson<List<String>>(reader, type) ?: emptyList()
        }
        catch (e: JsonSyntaxException) {
            // If parsing as a list fails, treat as a single string
            Log.w("ChangeWallpaperWorker", "Parsing as a list failed, trying as a single string", e)
            return  listOf(Gson().fromJson(reader, String::class.java))
        }
        catch (e: Exception) {
            Log.e("ChangeWallpaperWorker", "Error parsing string list", e)
            return emptyList()
        }
    }
}