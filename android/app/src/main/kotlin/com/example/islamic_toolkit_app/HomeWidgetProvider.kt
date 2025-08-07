package com.example.islamic_toolkit_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "HomeWidgetProvider"
        private const val ACTION_REFRESH = "com.example.islamic_toolkit_app.REFRESH_WIDGET"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "🔄 Widget onUpdate called for ${appWidgetIds.size} widgets")

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "✅ Widget enabled - first instance created")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "❌ Widget disabled - last instance removed")
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (ACTION_REFRESH == intent.action) {
            Log.d(TAG, "🔄 Refresh button pressed!")
            
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, HomeWidgetProvider::class.java)
            )
            
            // Send broadcast to Flutter app for data refresh (don't open app)
            try {
                val refreshBroadcast = Intent("com.example.islamic_toolkit_app.WIDGET_REFRESH").apply {
                    setPackage(context.packageName)
                }
                context.sendBroadcast(refreshBroadcast)
                Log.d(TAG, "✅ Refresh broadcast sent to Flutter")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error sending refresh broadcast: $e")
            }
            
            // Update all widgets immediately
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            Log.d(TAG, "🔥 UPDATED WIDGET WITH REFRESH - VERSION 8.0")
            Log.d(TAG, "📱 Updating widget $appWidgetId")

            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Default values
            var appName = "Islamic Toolkit"
            var currentPrayer = "Loading..."
            var nextPrayerName = "Loading..."
            var nextPrayerTime = "--:--:--"
            // Short Arabic duas only
            var randomDua = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ"

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
                        allKeys.entries.take(5).forEach { (key, value) ->
                            Log.d(TAG, "   📝 Sample: '$key' = '$value'")
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

            if (!dataFound) {
                Log.w(TAG, "⚠️ No widget data found in any SharedPreferences")
                currentPrayer = "No Data"
                nextPrayerName = "Tap refresh"
                nextPrayerTime = "to update"
                randomDua = "اللهم اعني على ذكرك وشكرك وحسن عبادتك"
            }

            Log.d(TAG, "✅ Final values:")
            Log.d(TAG, "   App Name: $appName")
            Log.d(TAG, "   Current Prayer: $currentPrayer")
            Log.d(TAG, "   Next Prayer Name: $nextPrayerName")
            Log.d(TAG, "   Next Prayer Time: $nextPrayerTime")
            Log.d(TAG, "   Random Dua: ${randomDua.take(30)}...")

            // Update widget views
            views.setTextViewText(R.id.app_name, appName)
            views.setTextViewText(R.id.current_prayer, if (currentPrayer.startsWith("Current:")) currentPrayer else "Current: $currentPrayer")
            views.setTextViewText(R.id.next_prayer_name, nextPrayerName)
            views.setTextViewText(R.id.next_prayer_time, if (nextPrayerTime.startsWith("in ")) nextPrayerTime else "in $nextPrayerTime")
            views.setTextViewText(R.id.random_dua, randomDua)
            
            // Set last updated time
            val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
            views.setTextViewText(R.id.last_updated, "Last updated: ${timeFormat.format(Date())}")

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

            // Set refresh button click intent (NO APP OPENING - JUST REFRESH)
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

            Log.d(TAG, "✅ Widget $appWidgetId updated successfully")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating widget $appWidgetId", e)

            // Fallback error view
            val errorViews = RemoteViews(context.packageName, R.layout.widget_layout)
            errorViews.setTextViewText(R.id.app_name, "Islamic Toolkit")
            errorViews.setTextViewText(R.id.current_prayer, "Error Loading")
            errorViews.setTextViewText(R.id.next_prayer_name, "Tap refresh")
            errorViews.setTextViewText(R.id.next_prayer_time, "to try again")
            errorViews.setTextViewText(R.id.random_dua, "لا حول ولا قوة إلا بالله")
            errorViews.setTextViewText(R.id.last_updated, "Error occurred")

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
}