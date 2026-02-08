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
 * Large PinnedNotesWidget (4x4) showing pinned notes in a 2x2 grid.
 * Displays up to 4 pinned notes with tap-to-view functionality.
 */
class PinnedNotesWidget : AppWidgetProvider() {

    companion object {
        private const val ACTION_VIEW_NOTE = "com.example.noteable_app.action.VIEW_PINNED_NOTE"
        private const val ACTION_UNPIN_NOTE = "com.example.noteable_app.action.UNPIN_NOTE"
        private const val EXTRA_APP_WIDGET_ID = "app_widget_id"
        private const val EXTRA_NOTE_ID = "note_id"
        private const val EXTRA_NOTE_INDEX = "note_index"

        private val widgetScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        /**
         * Updates all widget instances
         */
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, PinnedNotesWidget::class.java)
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
        when (intent.action) {
            ACTION_VIEW_NOTE -> {
                val noteId = intent.getLongExtra(EXTRA_NOTE_ID, 0L)
                if (noteId != 0L) {
                    handleViewNoteAction(context, noteId)
                }
            }
            ACTION_UNPIN_NOTE -> {
                val noteId = intent.getLongExtra(EXTRA_NOTE_ID, 0L)
                if (noteId != 0L) {
                    handleUnpinNoteAction(context, noteId)
                }
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

    private fun handleUnpinNoteAction(context: Context, noteId: Long) {
        widgetScope.launch {
            try {
                val dataStore = WidgetDataStore.getInstance(context)

                // Unpin the note via deep link
                val unpinIntent = createUnpinNoteIntent(context, noteId).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(unpinIntent)

                // Refresh widget after unpin
                withContext(Dispatchers.Main) {
                    updateAllWidgets(context)
                }
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

    private fun createUnpinNoteIntent(context: Context, noteId: Long): Intent {
        // Deep link to unpin a note in the Flutter app
        return Intent(
            Intent.ACTION_VIEW,
            Uri.parse("noteable://unpin-note/$noteId"),
            context,
            MainActivity::class.java
        )
    }
}

/**
 * Data class to hold note information for display
 */
private data class PinnedNoteDisplayInfo(
    val id: Long,
    val title: String,
    val preview: String,
    val isPinned: Boolean
)

/**
 * Updates the widget UI for given app widget IDs
 */
private fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray
) {
    // Use coroutine to fetch pinned notes
    CoroutineScope(Dispatchers.Main).launch {
        try {
            val dataStore = WidgetDataStore.getInstance(context)
            var currentNote: PinnedNoteDisplayInfo? = null

            // Get note data from data store
            dataStore.noteData.collect { note ->
                currentNote = if (note != null && note.isPinned) {
                    PinnedNoteDisplayInfo(
                        id = note.id,
                        title = note.title.ifEmpty { context.getString(R.string.untitled_note) },
                        preview = if (note.content.length > 40) {
                            note.content.take(40) + "..."
                        } else {
                            note.content
                        }.ifEmpty { context.getString(R.string.tap_to_view) },
                        isPinned = note.isPinned
                    )
                } else {
                    null
                }

                // Update each widget
                for (appWidgetId in appWidgetIds) {
                    val views = RemoteViews(context.packageName, R.layout.pinned_notes_widget)

                    // For now, we'll display the single pinned note in the first slot
                    // This will be expanded when the data store supports multiple pinned notes
                    val pinnedNotes = listOf(currentNote, null, null, null)

                    // Update each note slot in 2x2 grid
                    updatePinnedNoteSlot(views, context, R.id.note_1_title, R.id.note_1_preview, R.id.note_1_container, R.id.note_1_pin, pinnedNotes[0], appWidgetId, 0)
                    updatePinnedNoteSlot(views, context, R.id.note_2_title, R.id.note_2_preview, R.id.note_2_container, R.id.note_2_pin, pinnedNotes[1], appWidgetId, 1)
                    updatePinnedNoteSlot(views, context, R.id.note_3_title, R.id.note_3_preview, R.id.note_3_container, R.id.note_3_pin, pinnedNotes[2], appWidgetId, 2)
                    updatePinnedNoteSlot(views, context, R.id.note_4_title, R.id.note_4_preview, R.id.note_4_container, R.id.note_4_pin, pinnedNotes[3], appWidgetId, 3)

                    // Show/hide empty state
                    val hasNotes = pinnedNotes.any { it != null }
                    views.setViewVisibility(R.id.empty_state_text, if (hasNotes) android.view.View.GONE else android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.pinned_notes_container, if (hasNotes) android.view.View.VISIBLE else android.view.View.GONE)

                    // Update widget
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }
                return@collect
            }
        } catch (e: Exception) {
            // Use default UI on error
            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.pinned_notes_widget)
                views.setViewVisibility(R.id.empty_state_text, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.pinned_notes_container, android.view.View.GONE)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}

/**
 * Updates a single pinned note slot in the widget
 */
private fun updatePinnedNoteSlot(
    views: RemoteViews,
    context: Context,
    titleId: Int,
    previewId: Int,
    containerId: Int,
    pinIconId: Int,
    note: PinnedNoteDisplayInfo?,
    appWidgetId: Int,
    slotIndex: Int
) {
    if (note != null) {
        views.setViewVisibility(containerId, android.view.View.VISIBLE)
        views.setTextViewText(titleId, note.title)
        views.setTextViewText(previewId, note.preview)
        views.setViewVisibility(pinIconId, android.view.View.VISIBLE)

        // Set click listener for viewing the note
        val viewIntent = Intent(context, PinnedNotesWidget::class.java).apply {
            action = PinnedNotesWidget.ACTION_VIEW_NOTE
            putExtra(PinnedNotesWidget.EXTRA_NOTE_ID, note.id)
            putExtra(PinnedNotesWidget.EXTRA_NOTE_INDEX, slotIndex)
            data = Uri.parse("view_pinned_note://$appWidgetId/$slotIndex")
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
