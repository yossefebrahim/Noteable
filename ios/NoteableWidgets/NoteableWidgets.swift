import WidgetKit
import SwiftUI

struct NoteableWidget: Widget {
  let kind: String = "NoteableWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: NoteableProvider()) { entry in
      NoteableWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Quick Note")
    .description("Quickly capture notes from your home screen")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct NoteableWidgetEntryView: View {
  var entry: NoteableProvider.Entry

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 8) {
        Text("Noteable")
          .font(.headline)
          .foregroundColor(.white)

        if let note = entry.note {
          VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(.white)
              .lineLimit(1)

            Text(note.content)
              .font(.caption)
              .foregroundColor(.white.opacity(0.9))
              .lineLimit(3)
          }
        } else {
          Text("Tap to create a note")
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
        }

        Spacer()

        Text(entry.date, style: .time)
          .font(.caption2)
          .foregroundColor(.white.opacity(0.7))
      }
      .padding()
    }
  }
}

struct NoteableProvider: TimelineProvider {
  typealias Entry = NoteableEntry

  func placeholder(in context: Context) -> Entry {
    Entry(date: Date(), note: NoteDataModel(
      id: "placeholder",
      title: "Sample Note",
      content: "This is a preview of your note widget",
      createdAt: Date(),
      updatedAt: Date()
    ))
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    let entry = Entry(date: Date(), note: NoteDataModel(
      id: "snapshot",
      title: "Recent Note",
      content: "Your recent note will appear here",
      createdAt: Date(),
      updatedAt: Date()
    ))
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchNotes()

    let note = notes.first
    let entry = Entry(date: Date(), note: note)

    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}

struct NoteableEntry: TimelineEntry {
  let date: Date
  let note: NoteDataModel?
}
