package com.example.carousel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class WallpaperRestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action
        Log.d("WallpaperRestartReceiver", "Received action: $action")

        if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_PACKAGE_RESTARTED) {
            Log.d("WallpaperRestartReceiver", "Restarting WallpaperChangeService")
            val serviceIntent = Intent(context, WallpaperChangeService::class.java)
            serviceIntent.putExtra("isRandom", true) // Default behavior; customize as needed
            ContextCompat.startForegroundService(context!!, serviceIntent)
        }
    }
}
