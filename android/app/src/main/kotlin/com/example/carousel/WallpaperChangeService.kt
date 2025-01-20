package com.example.carousel

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder
import android.util.Log
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class WallpaperChangeService : Service() {

    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val TAG = "WallpaperChangeService"
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate called")
        startForeground(1, NotificationHelper.createForegroundNotification(this))
//        registerReceiver()
    }

    override fun onDestroy() {
        Log.d(TAG, "Service onDestroy called")
        unregisterReceiver(wallpaperChangeReceiver)
        wallpaperChangeReceiver = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val isRandom = intent?.getBooleanExtra("isRandom", true) ?: true

        Log.d(TAG, "Service onStartCommand called with isRandom = $isRandom")
        // Pass isRandom to the BroadcastReceiver registration
        registerReceiver(isRandom)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun registerReceiver(isRandom: Boolean) {
        Log.d(TAG, "registerReceiver called")
        wallpaperChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d(TAG, "Intent received: ${intent?.action}")
                if (intent?.action == Intent.ACTION_SCREEN_ON) {
                    Log.d(TAG, "Screen is on intent")
                     startWallpaperChangeWork(context!!, isRandom)
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(wallpaperChangeReceiver, filter)
        Log.d(TAG, "receiver registered")

    }

    private fun startWallpaperChangeWork(context: Context, isRandom: Boolean) {
        Log.d(TAG, "startWallpaperChangeWork called")
        val workRequest = OneTimeWorkRequestBuilder<ChangeWallpaperWorker>()
            .setInputData(androidx.work.Data.Builder().putBoolean("isRandom", isRandom).build())
            .build()
        WorkManager.getInstance(context).enqueue(workRequest)
        Log.d(TAG, "WorkManager enqueued with isRandom = $isRandom")
    }
}