package com.example.carousel

import android.annotation.TargetApi
import android.app.ActivityManager
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
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class WallpaperChangeService : Service() {
    private var screenOnReceiver: BroadcastReceiver? = null
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var wallpaperManager: WallpaperManagerHelper
    private var preferencesListener: SharedPreferences.OnSharedPreferenceChangeListener? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        acquireWakeLock()
        initializeForegroundService()
        initializeWallpaperManager()
        registerReceivers()
        setupPreferenceListener()
    }

    override fun onDestroy() {
        cleanupResources()
        super.onDestroy()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let { handleStartCommand(it) }
        return START_REDELIVER_INTENT
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // region Service Setup
    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "Carousel::WallpaperChangeLock"
            ).apply {
                acquire(10_000) // 10 second timeout for safety
            }
        } catch (e: Exception) {
            Log.e("WallpaperService", "WakeLock acquisition failed: ${e.message}")
        }
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private fun initializeForegroundService() {
        val notification = NotificationHelper.createForegroundNotification(this).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                priority = NotificationCompat.PRIORITY_MIN
            }
        }
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun initializeWallpaperManager() {
        wallpaperManager = WallpaperManagerHelper(this).also {
            it.loadWallpapersFromPreferences()
        }
    }
    // endregion

    // region Broadcast Handling
    private fun registerReceivers() {
        registerScreenOnReceiver()
    }

    private fun registerScreenOnReceiver() {
        screenOnReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_ON) {
                    handleScreenWakeEvent()
                }
            }
        }.also { receiver ->
            val filter = IntentFilter(Intent.ACTION_SCREEN_ON).apply {
                priority = IntentFilter.SYSTEM_HIGH_PRIORITY
            }
            registerReceiver(receiver, filter)
        }
    }
    // endregion

    // region Event Handling
    private fun handleStartCommand(intent: Intent) {
        intent.getBooleanExtra("isRandom", true).let { isRandom ->
            wallpaperManager.updateConfiguration(isRandom)
        }
    }

    private fun handleScreenWakeEvent() {
        Log.d("WallpaperService", "Screen wake event detected")
        serviceScope.launch {
            try {
                wallpaperManager.changeWallpaper()
            } catch (e: Exception) {
                Log.e("WallpaperService", "Wallpaper change failed: ${e.message}")
            }
        }
    }
    // endregion

    // region Preference Handling
    private fun setupPreferenceListener() {
        preferencesListener = SharedPreferences.OnSharedPreferenceChangeListener { prefs, key ->
            when (key) {
                "flutter.lock_screen_random" -> handleRandomPreferenceChange(prefs)
                "flutter.lock_screen_wallpapers" -> handleWallpapersPreferenceChange()
            }
        }.also {
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .registerOnSharedPreferenceChangeListener(it)
        }
    }

    private fun handleRandomPreferenceChange(prefs: SharedPreferences) {
        prefs.getBoolean("flutter.lock_screen_random", true).let { isRandom ->
            wallpaperManager.updateConfiguration(isRandom)
        }
    }

    private fun handleWallpapersPreferenceChange() {
        wallpaperManager.loadWallpapersFromPreferences()
        preloadNextWallpaper()
    }
    // endregion

    // region Resource Cleanup
    private fun cleanupResources() {
        unregisterReceivers()
        releaseWakeLock()
        serviceScope.cancel()
    }

    private fun unregisterReceivers() {
        screenOnReceiver?.let { unregisterReceiver(it) }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) it.release()
            }
        } catch (e: Exception) {
            Log.e("WallpaperService", "WakeLock release failed: ${e.message}")
        }
    }
    // endregion

    // region Service Resilience
    @TargetApi(Build.VERSION_CODES.M)
    override fun onTaskRemoved(rootIntent: Intent?) {
        scheduleServiceRestart()
        super.onTaskRemoved(rootIntent)
    }

    @TargetApi(Build.VERSION_CODES.M)
    private fun scheduleServiceRestart() {
        Log.d("WallpaperService", "Scheduling service restart")
        val restartIntent = Intent(applicationContext, WallpaperChangeService::class.java).apply {
            setPackage(packageName)
        }

        val pendingIntent = PendingIntent.getService(
            this,
            RESTART_REQUEST_CODE,
            restartIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        (getSystemService(Context.ALARM_SERVICE) as AlarmManager).apply {
            setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                System.currentTimeMillis() + RESTART_DELAY_MS,
                pendingIntent
            )
        }
    }

    private fun preloadNextWallpaper() {
        serviceScope.launch {
            wallpaperManager.preloadNextWallpaper()
        }
    }
    // endregion

    companion object {
        private const val NOTIFICATION_ID = 101
        private const val RESTART_REQUEST_CODE = 1001
        private const val RESTART_DELAY_MS = 1000L

        fun isRunning(context: Context): Boolean {
            val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            return manager.getRunningServices(Integer.MAX_VALUE)
                .any { it.service.className == WallpaperChangeService::class.java.name }
        }
    }
}