package com.example.islamic_toolkit_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "HomeWidgetProvider"
        private const val ACTION_REFRESH = "com.example.islamic_toolkit_app.REFRESH_WIDGET"
        private const val ACTION_AUTO_UPDATE = "com.example.islamic_toolkit_app.AUTO_UPDATE_WIDGET"
        private const val ACTION_TIMER_TICK = "com.example.islamic_toolkit_app.TIMER_TICK"
        
        // Auto-update interval (1 hour = 3600000 milliseconds)
        private const val UPDATE_INTERVAL_MS = 3600000L // 1 hour
        
        // Timer tick interval (1 second = 1000 milliseconds)
        private const val TIMER_TICK_INTERVAL_MS = 1000L // 1 second
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "🔄 Widget onUpdate called for ${appWidgetIds.size} widgets")

        // Schedule periodic auto-updates
        scheduleAutoUpdates(context)
        
        // Start timer updates (every second)
        scheduleTimerUpdates(context)

        // Update all widgets
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "✅ Widget enabled - first instance created")
        
        // Schedule auto-updates when widget is first added
        scheduleAutoUpdates(context)
        // Start timer updates
        scheduleTimerUpdates(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "❌ Widget disabled - last instance removed")
        
        // Cancel all updates when last widget is removed
        cancelAutoUpdates(context)
        cancelTimerUpdates(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_REFRESH -> {
                Log.d(TAG, "🔄 Manual refresh button pressed!")
                handleRefresh(context, isManual = true)
            }
            ACTION_AUTO_UPDATE -> {
                Log.d(TAG, "⏰ Auto-update triggered by AlarmManager")
                handleRefresh(context, isManual = false)
                
                // Reschedule next auto-update
                scheduleAutoUpdates(context)
            }
            ACTION_TIMER_TICK -> {
                Log.d(TAG, "⏱️ Timer tick - updating time display")
                handleTimerTick(context)
                
                // Reschedule next timer tick
                scheduleTimerUpdates(context)
            }
        }
    }

    private fun handleRefresh(context: Context, isManual: Boolean) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, HomeWidgetProvider::class.java)
        )
        
        if (isManual) {
            // For manual refresh, try to notify Flutter app if it's running
            try {
                val refreshBroadcast = Intent("com.example.islamic_toolkit_app.WIDGET_REFRESH").apply {
                    setPackage(context.packageName)
                }
                context.sendBroadcast(refreshBroadcast)
                Log.d(TAG, "✅ Refresh broadcast sent to Flutter")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error sending refresh broadcast: $e")
            }
        }
        
        // Update all widgets immediately
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun handleTimerTick(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, HomeWidgetProvider::class.java)
        )
        
        // Update timer display only (light update)
        for (appWidgetId in appWidgetIds) {
            updateTimerOnly(context, appWidgetManager, appWidgetId)
        }
    }

    private fun scheduleAutoUpdates(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_AUTO_UPDATE
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                100, // Unique request code for auto-update
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Cancel any existing alarms first
            alarmManager.cancel(pendingIntent)
            
            // Schedule next update
            val nextUpdateTime = SystemClock.elapsedRealtime() + UPDATE_INTERVAL_MS
            
            // Use setExactAndAllowWhileIdle for better reliability on newer Android versions
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    nextUpdateTime,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    nextUpdateTime,
                    pendingIntent
                )
            }
            
            Log.d(TAG, "⏰ Auto-update scheduled for ${UPDATE_INTERVAL_MS / 1000 / 60} minutes from now")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error scheduling auto-updates: $e")
        }
    }

    private fun scheduleTimerUpdates(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_TIMER_TICK
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                200, // Unique request code for timer updates
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Cancel any existing timer alarms first
            alarmManager.cancel(pendingIntent)
            
            // Schedule next timer tick (1 second from now)
            val nextTickTime = SystemClock.elapsedRealtime() + TIMER_TICK_INTERVAL_MS
            
            // Use setExactAndAllowWhileIdle for precise timing
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    nextTickTime,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    nextTickTime,
                    pendingIntent
                )
            }
            
            // Log only every 30 seconds to avoid spam
            if (System.currentTimeMillis() % 30000 < 1000) {
                Log.d(TAG, "⏱️ Timer tick scheduled")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error scheduling timer updates: $e")
        }
    }

    private fun cancelAutoUpdates(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_AUTO_UPDATE
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                100,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "⏰ Auto-updates cancelled")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error cancelling auto-updates: $e")
        }
    }

    private fun cancelTimerUpdates(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_TIMER_TICK
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                200,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "⏱️ Timer updates cancelled")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error cancelling timer updates: $e")
        }
    }

    private fun updateTimerOnly(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // Update only the timer display - get current time
            val currentTime = Calendar.getInstance()
            val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
            val currentTimeString = timeFormat.format(currentTime.time)
            
            // Update ONLY the separate timer display (not app name)
            views.setTextViewText(R.id.current_time_display, currentTimeString)
            
            // Update the widget with only the timer changes
            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating timer for widget $appWidgetId", e)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            Log.d(TAG, "🔥 UPDATED WIDGET - CLEAN VERSION 12.0 (Fixed Timer)")
            Log.d(TAG, "📱 Updating widget $appWidgetId at ${getCurrentTime()}")

            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Get current time for timer display
            val currentTime = Calendar.getInstance()
            val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
            val currentTimeString = timeFormat.format(currentTime.time)

            // Default values
            var appName = "Islamic Toolkit"
            var currentPrayer = "Loading..."
            var nextPrayerName = "Loading..."
            var nextPrayerTime = "--:--:--"
            var randomDua = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ"

            // Short Arabic duas for fallback when no app data
            val fallbackDuas = listOf(
                "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                "لَا إِلَهَ إِلَّا اللَّهُ",
                "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
                "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ",
                "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً",
                "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
                "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ"
            )

            // All possible SharedPreferences sources to check
            val sources = listOf(
                "FlutterSharedPreferences",
                "HomeWidgetPreferences", 
                "group.islamic_toolkit_app",
                "group.com.example.islamic_toolkit_app"
            )

            var dataFound = false

            for (sourceName in sources) {
                try {
                    val prefs = context.getSharedPreferences(sourceName, Context.MODE_PRIVATE)
                    val allKeys = prefs.all

                    Log.d(TAG, "🔍 Checking $sourceName (${allKeys.size} keys)")

                    if (allKeys.isNotEmpty()) {
                        // Log first few keys for debugging
                        allKeys.entries.take(3).forEach { (key, value) ->
                            Log.d(TAG, "   📝 Sample: '$key' = '${value.toString().take(30)}...'")
                        }
                    }

                    // Look for data with 'flutter.' prefix first
                    prefs.getString("flutter.app_name", null)?.let { 
                        appName = it
                        dataFound = true
                    }
                    prefs.getString("flutter.current_prayer", null)?.let { 
                        currentPrayer = it
                        dataFound = true
                    }
                    prefs.getString("flutter.next_prayer_name", null)?.let { 
                        nextPrayerName = it
                        dataFound = true
                    }
                    prefs.getString("flutter.next_prayer_time", null)?.let { 
                        nextPrayerTime = it
                        dataFound = true
                    }
                    prefs.getString("flutter.random_dua", null)?.let { duaText ->
                        // Extract only Arabic part (before newline)
                        val arabicOnly = duaText.split("\n")[0].trim()
                        if (arabicOnly.isNotEmpty()) {
                            randomDua = arabicOnly
                        }
                        dataFound = true
                    }

                    // Also check without prefix for backward compatibility
                    if (!dataFound) {
                        prefs.getString("app_name", null)?.let { appName = it; dataFound = true }
                        prefs.getString("current_prayer", null)?.let { currentPrayer = it; dataFound = true }
                        prefs.getString("next_prayer_name", null)?.let { nextPrayerName = it; dataFound = true }
                        prefs.getString("next_prayer_time", null)?.let { nextPrayerTime = it; dataFound = true }
                        prefs.getString("random_dua", null)?.let { duaText ->
                            val arabicOnly = duaText.split("\n")[0].trim()
                            if (arabicOnly.isNotEmpty()) {
                                randomDua = arabicOnly
                            }
                            dataFound = true
                        }
                    }

                    // Handle legacy next_prayer field
                    prefs.getString("next_prayer", null)?.let { nextPrayerLegacy ->
                        if (nextPrayerLegacy.isNotEmpty() && nextPrayerLegacy.contains(" in ")) {
                            val parts = nextPrayerLegacy.split(" in ")
                            if (parts.size >= 2) {
                                nextPrayerName = parts[0].trim()
                                nextPrayerTime = parts[1].trim()
                                dataFound = true
                            }
                        }
                    }

                    if (dataFound) {
                        Log.d(TAG, "✅ Found data in $sourceName")
                        break
                    }

                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error reading $sourceName: $e")
                }
            }

            // If no app data found, use fallback data with rotating dua
            if (!dataFound) {
                Log.w(TAG, "⚠️ No widget data found, using fallback with timestamp")
                
                val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                val duaIndex = currentHour % fallbackDuas.size
                randomDua = fallbackDuas[duaIndex]
                
                // Generate basic prayer schedule based on current time
                val (currentPrayerFallback, nextPrayerFallback, timeLeftFallback) = generateFallbackPrayerData()
                currentPrayer = currentPrayerFallback
                nextPrayerName = nextPrayerFallback
                nextPrayerTime = timeLeftFallback
                
                Log.d(TAG, "🔄 Using fallback dua index $duaIndex: ${randomDua.take(20)}...")
            }

            Log.d(TAG, "✅ Final values:")
            Log.d(TAG, "   App Name: $appName")
            Log.d(TAG, "   Current Time: $currentTimeString")
            Log.d(TAG, "   Current Prayer: $currentPrayer")
            Log.d(TAG, "   Next Prayer Name: $nextPrayerName")
            Log.d(TAG, "   Next Prayer Time: $nextPrayerTime")
            Log.d(TAG, "   Random Dua: ${randomDua.take(30)}...")

            // Update widget views - FIXED: No timer in app name, separate timer display
            views.setTextViewText(R.id.app_name, appName) // Just app name without timer
            views.setTextViewText(R.id.current_time_display, currentTimeString) // Separate timer
            views.setTextViewText(R.id.current_prayer, if (currentPrayer.startsWith("Current:")) currentPrayer else "Current: $currentPrayer")
            views.setTextViewText(R.id.next_prayer_name, nextPrayerName)
            views.setTextViewText(R.id.next_prayer_time, if (nextPrayerTime.startsWith("in ")) nextPrayerTime else "in $nextPrayerTime")
            views.setTextViewText(R.id.random_dua, randomDua)

            // Set click intent to open app
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val openAppPendingIntent = PendingIntent.getActivity(
                context,
                0,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_root, openAppPendingIntent)

            // Set refresh button click intent
            val refreshIntent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }

            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                1,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)

            Log.d(TAG, "✅ Widget $appWidgetId updated successfully at ${getCurrentTime()}")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating widget $appWidgetId", e)

            // Fallback error view
            val errorViews = RemoteViews(context.packageName, R.layout.widget_layout)
            errorViews.setTextViewText(R.id.app_name, "Islamic Toolkit")
            errorViews.setTextViewText(R.id.current_time_display, getCurrentTime())
            errorViews.setTextViewText(R.id.current_prayer, "Error Loading")
            errorViews.setTextViewText(R.id.next_prayer_name, "Tap refresh")
            errorViews.setTextViewText(R.id.next_prayer_time, "to try again")
            errorViews.setTextViewText(R.id.random_dua, "لا حول ولا قوة إلا بالله")

            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            errorViews.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, errorViews)
        }
    }

    private fun generateFallbackPrayerData(): Triple<String, String, String> {
        val calendar = Calendar.getInstance()
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
        val currentMinute = calendar.get(Calendar.MINUTE)
        
        // Simple fallback prayer times (approximate)
        return when (currentHour) {
            in 0..4 -> Triple("Isha", "Fajr", String.format("%02d:%02d:00", 5 - currentHour - if (currentMinute > 0) 0 else 1, if (currentMinute > 0) 60 - currentMinute else 0))
            5 -> Triple("Fajr", "Sunrise", String.format("01:%02d:00", if (currentMinute < 30) 30 - currentMinute else 90 - currentMinute))
            in 6..11 -> Triple("Sunrise", "Dhuhr", String.format("%02d:%02d:00", 12 - currentHour - if (currentMinute > 0) 0 else 1, if (currentMinute > 0) 60 - currentMinute else 0))
            12 -> Triple("Dhuhr", "Asr", String.format("03:%02d:00", if (currentMinute < 30) 30 - currentMinute else 90 - currentMinute))
            in 13..14 -> Triple("Dhuhr", "Asr", String.format("%02d:%02d:00", 15 - currentHour - if (currentMinute > 0) 0 else 1, if (currentMinute > 0) 60 - currentMinute else 0))
            15 -> Triple("Asr", "Maghrib", String.format("03:%02d:00", if (currentMinute < 30) 30 - currentMinute else 90 - currentMinute))
            in 16..17 -> Triple("Asr", "Maghrib", String.format("%02d:%02d:00", 18 - currentHour - if (currentMinute > 0) 0 else 1, if (currentMinute > 0) 60 - currentMinute else 0))
            18 -> Triple("Maghrib", "Isha", String.format("01:%02d:00", if (currentMinute < 30) 30 - currentMinute else 90 - currentMinute))
            in 19..23 -> Triple("Maghrib", "Isha", String.format("%02d:%02d:00", 20 - currentHour - if (currentMinute > 0) 0 else 1, if (currentMinute > 0) 60 - currentMinute else 0))
            else -> Triple("Unknown", "Fajr", "05:00:00")
        }
    }

    private fun getCurrentTime(): String {
        return SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
    }
}