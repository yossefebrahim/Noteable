import Foundation

class WidgetDataStore {
  static let shared = WidgetDataStore()

  private let suiteName: String
  private let notesKey: String = "shared_notes"

  init(suiteName: String = "group.com.noteable.app") {
    self.suiteName = suiteName
  }

  private var userDefaults: UserDefaults? {
    UserDefaults(suiteName: suiteName)
  }

  func fetchNotes() -> [NoteDataModel] {
    guard let data = userDefaults?.data(forKey: notesKey),
          let notes = try? JSONDecoder().decode([NoteDataModel].self, from: data) else {
      return []
    }
    return notes.sorted { $0.updatedAt > $1.updatedAt }
  }

  func fetchPinnedNotes() -> [NoteDataModel] {
    let notes = fetchNotes()
    return notes.filter { $0.isPinned }.sorted { $0.updatedAt > $1.updatedAt }
  }

  func saveNote(_ note: NoteDataModel) {
    var notes = fetchNotes()

    if let index = notes.firstIndex(where: { $0.id == note.id }) {
      var updatedNote = note
      updatedNote.updatedAt = Date()
      notes[index] = updatedNote
    } else {
      notes.append(note)
    }

    saveNotes(notes)
  }

  func deleteNote(id: String) {
    var notes = fetchNotes()
    notes.removeAll { $0.id == id }
    saveNotes(notes)
  }

  private func saveNotes(_ notes: [NoteDataModel]) {
    guard let data = try? JSONEncoder().encode(notes) else {
      return
    }
    userDefaults?.set(data, forKey: notesKey)
  }
}
