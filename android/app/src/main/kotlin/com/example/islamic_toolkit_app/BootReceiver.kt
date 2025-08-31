package com.example.islamic_toolkit_app

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "🔄 Boot receiver triggered: ${intent.action}")

        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                try {
                    Log.d(TAG, "📱 Device/app restarted, reinitializing widget updates...")

                    // Get all active widgets
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val componentName = ComponentName(context, HomeWidgetProvider::class.java)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

                    if (appWidgetIds.isNotEmpty()) {
                        Log.d(TAG, "✅ Found ${appWidgetIds.size} active widgets, triggering update...")

                        // Create an intent to trigger widget update
                        val updateIntent = Intent(context, HomeWidgetProvider::class.java).apply {
                            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                        }

                        // Send the broadcast to update widgets
                        context.sendBroadcast(updateIntent)

                        Log.d(TAG, "🚀 Widget update broadcast sent successfully")
                    } else {
                        Log.d(TAG, "ℹ️ No active widgets found")
                    }

                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error in boot receiver: $e")
                }
            }
        }
    }
}