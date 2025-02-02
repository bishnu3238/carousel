package com.example.carousel

import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.work.*


class WallpaperRestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action
        Log.d("WallpaperRestartReceiver", "Received action: $action")

        if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_PACKAGE_RESTARTED) {
            Log.d("WallpaperRestartReceiver", "Restarting WallpaperChangeService")
            val serviceIntent = Intent(context, WallpaperChangeService::class.java)
            serviceIntent.putExtra("isRandom", true) // Default behavior; customize as needed
            ContextCompat.startForegroundService(context!!, serviceIntent)
            restartWallpaperService(context)

        }
    }

    private fun restartWallpaperService(context: Context) {
        val workRequest = OneTimeWorkRequestBuilder<WallpaperRestartWorker>()
            .setInitialDelay(5, java.util.concurrent.TimeUnit.SECONDS)
            .build()
        WorkManager.getInstance(context).enqueue(workRequest)
    }

}


class WallpaperRestartWorker(context: Context, workerParams: WorkerParameters) :
    Worker(context, workerParams) {
    @TargetApi(Build.VERSION_CODES.GINGERBREAD)
    override fun doWork(): Result {
        val serviceIntent = Intent(applicationContext, WallpaperChangeService::class.java)
        serviceIntent.putExtra("isRandom", true)
        applicationContext.startForegroundService(serviceIntent)
        val nextRestart = PeriodicWorkRequestBuilder<WallpaperRestartWorker>(
            15, java.util.concurrent.TimeUnit.MINUTES
        ).build()
        WorkManager.getInstance(applicationContext).enqueue(nextRestart)
        return Result.success()
    }
}