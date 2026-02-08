package com.example.noteable_app.widget

import kotlinx.serialization.Serializable

/**
 * Data model representing a note for Android widget usage.
 * This class mirrors the Dart NoteModel structure for interoperability.
 */
@Serializable
data class NoteDataModel(
    val id: Long = 0,
    val title: String,
    val content: String,
    val createdAt: Long,
    val updatedAt: Long? = null,
    val isPinned: Boolean = false,
    val folderId: String? = null
) {
    companion object {
        /**
         * Creates a NoteDataModel from a map of string values (used for Flutter platform channel communication)
         */
        fun fromMap(map: Map<String, Any?>): NoteDataModel? {
            return try {
                NoteDataModel(
                    id = (map["id"] as? Number)?.toLong() ?: 0,
                    title = map["title"] as? String ?: "",
                    content = map["content"] as? String ?: "",
                    createdAt = (map["createdAt"] as? Number)?.toLong() ?: System.currentTimeMillis(),
                    updatedAt = (map["updatedAt"] as? Number)?.toLong(),
                    isPinned = map["isPinned"] as? Boolean ?: false,
                    folderId = map["folderId"] as? String
                )
            } catch (e: Exception) {
                null
            }
        }
    }

    /**
     * Converts the NoteDataModel to a map for Flutter platform channel communication
     */
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "id" to id,
            "title" to title,
            "content" to content,
            "createdAt" to createdAt,
            "updatedAt" to updatedAt,
            "isPinned" to isPinned,
            "folderId" to folderId
        )
    }
}
