package com.example.carousel

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

object NotificationHelper { 
    private const val CHANNEL_ID = "WallpaperServiceChannel"
    private const val TAG = "NotificationHelper"
    fun createForegroundNotification(context: Context): Notification {
        Log.d(TAG, "createForegroundNotification called")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Wallpaper Service",
                NotificationManager.IMPORTANCE_LOW
            )
            Log.d(TAG, "Notification channel created")
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("Wallpaper Change Service")
            .setContentText("Listening for screen on events")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MIN) // Lowest priority for less visibility
            .build()
    }
}