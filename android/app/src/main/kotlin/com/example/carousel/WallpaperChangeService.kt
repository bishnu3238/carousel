package com.example.carousel

import android.annotation.TargetApi
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.Constraints
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class WallpaperChangeService: Service() {

    private var wallpaperChangeReceiver: WallpaperChangeReceiver? = null
    private val FOREGROUND_CHANNEL_ID = "foreground_channel"
    override fun onBind(intent: Intent): IBinder? {
        return null
    }
    override fun onCreate() {
        startListeningScreenEvents()
        super.onCreate()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        startForeground(1, buildNotification())
        return START_STICKY
    }
    override fun onDestroy() {
        stopListeningScreenEvents()
        super.onDestroy()
    }
    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    private fun startListeningScreenEvents(){
        wallpaperChangeReceiver = WallpaperChangeReceiver()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(wallpaperChangeReceiver, filter)
        Log.d("WallpaperChangeService", "Started listening for screen on events.")
    }

    private fun stopListeningScreenEvents(){
        if (wallpaperChangeReceiver != null) {
            unregisterReceiver(wallpaperChangeReceiver)
            wallpaperChangeReceiver = null
            Log.d("WallpaperChangeService", "Stopped listening for screen on events.")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                FOREGROUND_CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, FOREGROUND_CHANNEL_ID)
            .setContentTitle("Wallpaper Change Service")
            .setContentText("Changing Wallpaper On Every Wake")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()
    }
    class WallpaperChangeReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_SCREEN_ON || intent.action == Intent.ACTION_USER_PRESENT) {
                Log.d("WallpaperChangeReceiver", "Screen is on")
                startWorkManager(context)
            }
        }
        private fun startWorkManager(context: Context){
            val constraints = Constraints.Builder()
                .setRequiresBatteryNotLow(true)
                .build()
            val workRequest = OneTimeWorkRequestBuilder<ChangeWallpaperWorker>()
                .setConstraints(constraints)
                .build()
            WorkManager.getInstance(context).enqueue(workRequest)
        }
    }
}