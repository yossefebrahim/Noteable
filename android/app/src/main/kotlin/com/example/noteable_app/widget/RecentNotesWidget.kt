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
 * Medium RecentNotesWidget (4x2) showing the last 3 notes.
 * Displays a list of recent notes with tap-to-view functionality.
 */
class RecentNotesWidget : AppWidgetProvider() {

    companion object {
        private const val ACTION_VIEW_NOTE = "com.example.noteable_app.action.VIEW_NOTE"
        private const val EXTRA_APP_WIDGET_ID = "app_widget_id"
        private const val EXTRA_NOTE_ID = "note_id"

        private val widgetScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        /**
         * Updates all widget instances
         */
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, RecentNotesWidget::class.java)
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
        if (ACTION_VIEW_NOTE == intent.action) {
            val noteId = intent.getLongExtra(EXTRA_NOTE_ID, 0L)
            if (noteId != 0L) {
                handleViewNoteAction(context, noteId)
            }
        }
    }

    private fun handleViewNoteAction(context: Context, noteId: Long) {
        widgetScope.launch {
            try {
                // Open the specific note via deep link
                val viewIntent = createViewNoteIntent(context, noteId).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(viewIntent)
            } catch (e: Exception) {
                // Handle error silently
            }
        }
    }

    private fun createViewNoteIntent(context: Context, noteId: Long): Intent {
        // Deep link to view a specific note in the Flutter app
        return Intent(
            Intent.ACTION_VIEW,
            Uri.parse("noteable://view-note/$noteId"),
            context,
            MainActivity::class.java
        )
    }
}

/**
 * Data class to hold note information for display
 */
private data class NoteDisplayInfo(
    val id: Long,
    val title: String,
    val preview: String
)

/**
 * Updates the widget UI for given app widget IDs
 */
private fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray
) {
    // Use coroutine to fetch recent notes
    CoroutineScope(Dispatchers.Main).launch {
        try {
            val dataStore = WidgetDataStore.getInstance(context)
            var currentNote: NoteDisplayInfo? = null

            // Get note data from data store
            dataStore.noteData.collect { note ->
                currentNote = if (note != null) {
                    NoteDisplayInfo(
                        id = note.id,
                        title = note.title.ifEmpty { context.getString(R.string.untitled_note) },
                        preview = if (note.content.length > 50) {
                            note.content.take(50) + "..."
                        } else {
                            note.content
                        }.ifEmpty { context.getString(R.string.tap_to_view) }
                    )
                } else {
                    null
                }

                // Update each widget
                for (appWidgetId in appWidgetIds) {
                    val views = RemoteViews(context.packageName, R.layout.recent_notes_widget)

                    // For now, we'll display the single note in all three slots
                    // This will be expanded when the data store supports multiple notes
                    val notes = listOf(currentNote, null, null)

                    // Update each note slot
                    updateNoteSlot(views, context, R.id.note_1_title, R.id.note_1_preview, R.id.note_1_container, notes[0], appWidgetId, 0)
                    updateNoteSlot(views, context, R.id.note_2_title, R.id.note_2_preview, R.id.note_2_container, notes[1], appWidgetId, 1)
                    updateNoteSlot(views, context, R.id.note_3_title, R.id.note_3_preview, R.id.note_3_container, notes[2], appWidgetId, 2)

                    // Show/hide empty state
                    val hasNotes = notes.any { it != null }
                    views.setViewVisibility(R.id.empty_state_text, if (hasNotes) android.view.View.GONE else android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.notes_container, if (hasNotes) android.view.View.VISIBLE else android.view.View.GONE)

                    // Update widget
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }
                return@collect
            }
        } catch (e: Exception) {
            // Use default UI on error
            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.recent_notes_widget)
                views.setViewVisibility(R.id.empty_state_text, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.notes_container, android.view.View.GONE)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}

/**
 * Updates a single note slot in the widget
 */
private fun updateNoteSlot(
    views: RemoteViews,
    context: Context,
    titleId: Int,
    previewId: Int,
    containerId: Int,
    note: NoteDisplayInfo?,
    appWidgetId: Int,
    slotIndex: Int
) {
    if (note != null) {
        views.setViewVisibility(containerId, android.view.View.VISIBLE)
        views.setTextViewText(titleId, note.title)
        views.setTextViewText(previewId, note.preview)

        // Set click listener for the note
        val viewIntent = Intent(context, RecentNotesWidget::class.java).apply {
            action = RecentNotesWidget.ACTION_VIEW_NOTE
            putExtra(RecentNotesWidget.EXTRA_NOTE_ID, note.id)
            data = Uri.parse("view_note://$appWidgetId/$slotIndex")
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId * 10 + slotIndex,
            viewIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        views.setOnClickPendingIntent(containerId, pendingIntent)
    } else {
        views.setViewVisibility(containerId, android.view.View.GONE)
    }
}
