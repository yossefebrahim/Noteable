package com.example.noteable_app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Small QuickCaptureWidget (2x2) for instant note capture.
 * Displays a capture button that opens the app for quick note creation.
 */
class QuickCaptureWidget : AppWidgetProvider() {

    companion object {
        private const val ACTION_CAPTURE = "com.example.noteable_app.action.CAPTURE"
        private const val EXTRA_APP_WIDGET_ID = "app_widget_id"

        private val widgetScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        /**
         * Updates all widget instances
         */
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, QuickCaptureWidget::class.java)
            )
            updateAppWidget(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetIds)
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (ACTION_CAPTURE == intent.action) {
            val appWidgetId = intent.getIntExtra(EXTRA_APP_WIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            handleCaptureAction(context, appWidgetId)
        }
    }

    private fun handleCaptureAction(context: Context, appWidgetId: Int) {
        widgetScope.launch {
            try {
                val dataStore = WidgetDataStore.getInstance(context)

                // Create a new note via deep link
                val captureIntent = createCaptureIntent(context).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(captureIntent)

                // Refresh widget after capture
                withContext(Dispatchers.Main) {
                    updateAppWidget(
                        context,
                        AppWidgetManager.getInstance(context),
                        intArrayOf(appWidgetId)
                    )
                }
            } catch (e: Exception) {
                // Handle error silently
            }
        }
    }

    private fun createCaptureIntent(context: Context): Intent {
        // Deep link to note detail in the Flutter app
        return Intent(
            Intent.ACTION_VIEW,
            Uri.parse("noteable://note-detail"),
            context,
            MainActivity::class.java
        )
    }
}

/**
 * Updates the widget UI for given app widget IDs
 */
private fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray
) {
    // Use coroutine to fetch note count
    CoroutineScope(Dispatchers.Main).launch {
        try {
            val dataStore = WidgetDataStore.getInstance(context)
            var noteCount = 0

            // Get note count from data store (simplified for now)
            dataStore.noteData.collect { note ->
                noteCount = if (note != null) 1 else 0

                // Update each widget
                for (appWidgetId in appWidgetIds) {
                    val views = RemoteViews(context.packageName, R.layout.quick_capture_widget)

                    // Set click listener for capture button
                    val captureIntent = Intent(context, QuickCaptureWidget::class.java).apply {
                        action = QuickCaptureWidget.ACTION_CAPTURE
                        putExtra(QuickCaptureWidget.EXTRA_APP_WIDGET_ID, appWidgetId)
                        data = Uri.parse("capture://$appWidgetId")
                    }

                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        appWidgetId,
                        captureIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    views.setOnClickPendingIntent(R.id.capture_button, pendingIntent)

                    // Update note count text
                    val countText = if (noteCount > 0) {
                        context.resources.getQuantityString(R.plurals.note_count, noteCount, noteCount)
                    } else {
                        context.getString(R.string.tap_to_capture)
                    }
                    views.setTextViewText(R.id.note_count_text, countText)

                    // Update widget
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }
                return@collect
            }
        } catch (e: Exception) {
            // Use default UI on error
            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.quick_capture_widget)
                views.setTextViewText(R.id.note_count_text, context.getString(R.string.tap_to_capture))

                val captureIntent = Intent(context, QuickCaptureWidget::class.java).apply {
                    action = QuickCaptureWidget.ACTION_CAPTURE
                    putExtra(QuickCaptureWidget.EXTRA_APP_WIDGET_ID, appWidgetId)
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    appWidgetId,
                    captureIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                views.setOnClickPendingIntent(R.id.capture_button, pendingIntent)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}
