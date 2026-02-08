package com.example.noteable_app.widget

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/**
 * DataStore for managing widget-related data persistence.
 * Provides a modern, type-safe alternative to SharedPreferences.
 */
private val Context.widgetDataStore: DataStore<Preferences> by preferencesDataStore(name = "widget_data")

class WidgetDataStore(private val context: Context) {

    companion object {
        private const val KEY_PREFIX = "widget_"

        /**
         * Preference keys for storing widget data
         */
        private val WIDGET_ENABLED = booleanPreferencesKey("${KEY_PREFIX}enabled")
        private val NOTE_ID = longPreferencesKey("${KEY_PREFIX}note_id")
        private val NOTE_TITLE = stringPreferencesKey("${KEY_PREFIX}note_title")
        private val NOTE_CONTENT = stringPreferencesKey("${KEY_PREFIX}note_content")
        private val NOTE_CREATED_AT = longPreferencesKey("${KEY_PREFIX}note_created_at")
        private val NOTE_UPDATED_AT = longPreferencesKey("${KEY_PREFIX}note_updated_at")
        private val NOTE_IS_PINNED = booleanPreferencesKey("${KEY_PREFIX}note_is_pinned")
        private val NOTE_FOLDER_ID = stringPreferencesKey("${KEY_PREFIX}note_folder_id")

        @Volatile
        private var instance: WidgetDataStore? = null

        /**
         * Gets the singleton instance of WidgetDataStore
         */
        fun getInstance(context: Context): WidgetDataStore {
            return instance ?: synchronized(this) {
                instance ?: WidgetDataStore(context.applicationContext).also { instance = it }
            }
        }
    }

    /**
     * Flow that emits the current note data
     */
    val noteData: Flow<NoteDataModel?> = context.widgetDataStore.data.map { preferences ->
        val noteId = preferences[NOTE_ID] ?: 0
        if (noteId == 0L) {
            return@map null
        }

        NoteDataModel(
            id = noteId,
            title = preferences[NOTE_TITLE] ?: "",
            content = preferences[NOTE_CONTENT] ?: "",
            createdAt = preferences[NOTE_CREATED_AT] ?: System.currentTimeMillis(),
            updatedAt = preferences[NOTE_UPDATED_AT],
            isPinned = preferences[NOTE_IS_PINNED] ?: false,
            folderId = preferences[NOTE_FOLDER_ID]
        )
    }

    /**
     * Flow that emits whether the widget is enabled
     */
    val isWidgetEnabled: Flow<Boolean> = context.widgetDataStore.data.map { preferences ->
        preferences[WIDGET_ENABLED] ?: false
    }

    /**
     * Saves note data to DataStore
     */
    suspend fun saveNoteData(note: NoteDataModel) {
        context.widgetDataStore.edit { preferences ->
            preferences[NOTE_ID] = note.id
            preferences[NOTE_TITLE] = note.title
            preferences[NOTE_CONTENT] = note.content
            preferences[NOTE_CREATED_AT] = note.createdAt
            preferences[NOTE_UPDATED_AT] = note.updatedAt ?: System.currentTimeMillis()
            preferences[NOTE_IS_PINNED] = note.isPinned
            preferences[NOTE_FOLDER_ID] = note.folderId ?: ""
            preferences[WIDGET_ENABLED] = true
        }
    }

    /**
     * Clears all widget data from DataStore
     */
    suspend fun clearNoteData() {
        context.widgetDataStore.edit { preferences ->
            preferences.clear()
        }
    }

    /**
     * Sets the widget enabled state
     */
    suspend fun setWidgetEnabled(enabled: Boolean) {
        context.widgetDataStore.edit { preferences ->
            preferences[WIDGET_ENABLED] = enabled
        }
    }

    /**
     * Gets the current note data synchronously (for use in Widget RemoteViewsFactory)
     * Note: This should be used sparingly as it's a blocking call
     */
    suspend fun getNoteDataSync(): NoteDataModel? {
        var result: NoteDataModel? = null
        context.widgetDataStore.data.collect { preferences ->
            val noteId = preferences[NOTE_ID] ?: 0
            if (noteId == 0L) {
                result = null
                return@collect
            }

            result = NoteDataModel(
                id = noteId,
                title = preferences[NOTE_TITLE] ?: "",
                content = preferences[NOTE_CONTENT] ?: "",
                createdAt = preferences[NOTE_CREATED_AT] ?: System.currentTimeMillis(),
                updatedAt = preferences[NOTE_UPDATED_AT],
                isPinned = preferences[NOTE_IS_PINNED] ?: false,
                folderId = preferences[NOTE_FOLDER_ID]
            )
        }
        return result
    }
}
