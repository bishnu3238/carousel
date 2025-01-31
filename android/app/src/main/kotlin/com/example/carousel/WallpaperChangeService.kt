package com.example.carousel

import android.annotation.TargetApi
import android.app.AlarmManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.os.Build
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class WallpaperChangeService : Service() {
    private var wallpaperChangeReceiver: BroadcastReceiver? = null
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private lateinit var wallpaperManager: WallpaperManagerHelper
    private var preferencesListener: SharedPreferences.OnSharedPreferenceChangeListener? = null

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onCreate() {
        super.onCreate()
        startForeground(1, NotificationHelper.createForegroundNotification(this))
        wallpaperManager = WallpaperManagerHelper(this) // Initialize here
        registerReceiver()
        registerPreferencesListener()
    }

    override fun onDestroy() {
        unregisterReceiver(wallpaperChangeReceiver)
        unregisterPreferencesListener()
        serviceScope.cancel()
        super.onDestroy()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            wallpaperManager.updateConfiguration(it.getBooleanExtra("isRandom", true))
        }
        return START_REDELIVER_INTENT
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun registerReceiver() {
        if (wallpaperChangeReceiver == null) {
            wallpaperChangeReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == Intent.ACTION_SCREEN_ON) {
                        serviceScope.launch { wallpaperManager.changeWallpaper() }
                    }
                }
            }
            val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
            registerReceiver(wallpaperChangeReceiver, filter)
            Log.d("WallpaperService", "Screen ON Receiver Registered")

        }
    }


    private fun unregisterReceiverSafely() {
        try {
            wallpaperChangeReceiver?.let {
                unregisterReceiver(it)
                Log.d("WallpaperService", "Receiver Unregistered")
            }
        } catch (e: Exception) {
            Log.e("WallpaperService", "Error unregistering receiver: ${e.localizedMessage}")
        }
    }

    private fun registerPreferencesListener() {
        val sharedPreferences =
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        preferencesListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
            when (key) {
                "flutter.lock_screen_random" -> {
                    val isRandom = sharedPreferences.getBoolean(key, true)
                    wallpaperManager.updateConfiguration(isRandom)
                }

                "flutter.lock_screen_wallpapers" -> {
                    wallpaperManager.loadWallpapersFromPreferences()
                }
            }
        }
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferencesListener)
    }

    private fun unregisterPreferencesListener() {
        preferencesListener?.let {
            val sharedPreferences =
                getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            sharedPreferences.unregisterOnSharedPreferenceChangeListener(it)
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    override fun onTaskRemoved(rootIntent: Intent?) {
        val restartServiceIntent = Intent(applicationContext, this::class.java).also {
            it.setPackage(packageName)
        }
        val pendingIntent = PendingIntent.getService(
            applicationContext, 1, restartServiceIntent, PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            System.currentTimeMillis() + 1000,
            pendingIntent
        )

        // Adding log for debugging service restart
        Log.d("WallpaperChangeService", "onTaskRemoved called. Restarting service.")

        super.onTaskRemoved(rootIntent)
    }
}
