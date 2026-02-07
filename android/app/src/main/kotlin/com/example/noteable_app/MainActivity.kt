package com.example.noteable_app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Handle deep links from widget taps
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle deep links when app is already running
        handleDeepLink(intent)
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
