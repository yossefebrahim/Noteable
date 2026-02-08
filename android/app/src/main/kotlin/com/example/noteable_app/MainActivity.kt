package com.example.noteable_app

import android.content.Intent
import android.os.Bundle
import com.example.noteable_app.widget.PinnedNotesWidget
import com.example.noteable_app.widget.QuickCaptureWidget
import com.example.noteable_app.widget.RecentNotesWidget
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val widgetChannel = "com.example.noteable/widgets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up widget refresh method channel
        setupWidgetRefreshChannel(flutterEngine)

        // Handle deep links from widget taps
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle deep links when app is already running
        handleDeepLink(intent)
    }

    // Set up method channel for widget refresh
    private fun setupWidgetRefreshChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "refreshWidgets") {
                    refreshAllWidgets()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    // Refresh all widget types
    private fun refreshAllWidgets() {
        QuickCaptureWidget.updateAllWidgets(this)
        RecentNotesWidget.updateAllWidgets(this)
        PinnedNotesWidget.updateAllWidgets(this)
    }

    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data ?: return

        // Handle deep links in the format: noteable://note-detail/{noteId}
        if (data.scheme == "noteable" && data.host == "note-detail") {
            val noteId = data.lastPathSegment
            if (!noteId.isNullOrEmpty()) {
                // Set initial route for Flutter navigation
                flutterEngine?.navigationChannel?.pushRoute("/note-detail/$noteId")
            }
        }
    }
}
