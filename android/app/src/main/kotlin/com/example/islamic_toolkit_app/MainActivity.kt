package com.example.islamic_toolkit_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.content.Context
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.islamic_toolkit_app/widget"
    private val TAG = "MainActivity"
    private var widgetRefreshReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshWidget" -> {
                    Log.d(TAG, "🔄 Flutter requested widget refresh")
                    result.success("Widget refresh triggered")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Register broadcast receiver for widget refresh
        registerWidgetRefreshReceiver()
    }

    private fun registerWidgetRefreshReceiver() {
        widgetRefreshReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == "com.example.islamic_toolkit_app.WIDGET_REFRESH") {
                    Log.d(TAG, "🔄 Widget refresh broadcast received")
                    
                    // Send message to Flutter to refresh widget data
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod("onWidgetRefreshRequested", null)
                    }
                }
            }
        }
        
        val filter = IntentFilter("com.example.islamic_toolkit_app.WIDGET_REFRESH")
        registerReceiver(widgetRefreshReceiver, filter)
        Log.d(TAG, "✅ Widget refresh receiver registered")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            if (it.getBooleanExtra("refresh_widget", false)) {
                Log.d(TAG, "🔄 Widget refresh requested via intent")
                
                // Send message to Flutter to refresh widget data
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, CHANNEL).invokeMethod("onWidgetRefreshRequested", null)
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        
        // Unregister broadcast receiver
        widgetRefreshReceiver?.let {
            try {
                unregisterReceiver(it)
                Log.d(TAG, "✅ Widget refresh receiver unregistered")
            } catch (e: Exception) {
                Log.w(TAG, "⚠️ Error unregistering receiver: $e")
            }
        }
        widgetRefreshReceiver = null
    }
}