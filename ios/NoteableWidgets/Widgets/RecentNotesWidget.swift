import WidgetKit
import SwiftUI

struct RecentNotesWidget: Widget {
  let kind: String = "RecentNotesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: RecentNotesProvider()) { entry in
      RecentNotesWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Recent Notes")
    .description("View your last 3 notes at a glance")
    .supportedFamilies([.systemMedium])
  }
}

struct RecentNotesWidgetEntryView: View {
  var entry: RecentNotesProvider.Entry

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 8) {
        Text("Recent Notes")
          .font(.headline)
          .foregroundColor(.white)

        if entry.notes.isEmpty {
          VStack {
            Text("No notes yet")
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.8))
            Text("Create your first note")
              .font(.caption)
              .foregroundColor(.white.opacity(0.7))
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          VStack(alignment: .leading, spacing: 6) {
            ForEach(entry.notes.prefix(3), id: \.id) { note in
              NoteRow(note: note)
            }

            if entry.notes.count > 3 {
              Text("+ \(entry.notes.count - 3) more")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            }
          }

          Spacer()

          Text("Updated: \(entry.date, style: .time)")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.7))
        }
      }
      .padding()
    }
  }
}

struct NoteRow: View {
  let note: NoteDataModel

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(note.title.isEmpty ? "Untitled" : note.title)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .lineLimit(1)

      Text(note.content.isEmpty ? "No content" : note.content)
        .font(.caption)
        .foregroundColor(.white.opacity(0.85))
        .lineLimit(1)
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 6)
        .fill(Color.white.opacity(0.15))
    )
  }
}

struct RecentNotesProvider: TimelineProvider {
  typealias Entry = RecentNotesEntry

  func placeholder(in context: Context) -> Entry {
    let sampleNotes = [
      NoteDataModel(
        id: "1",
        title: "Meeting Notes",
        content: "Discussed Q1 planning and goals",
        createdAt: Date(),
        updatedAt: Date()
      ),
      NoteDataModel(
        id: "2",
        title: "Shopping List",
        content: "Milk, eggs, bread, coffee",
        createdAt: Date(),
        updatedAt: Date().addingTimeInterval(-3600)
      ),
      NoteDataModel(
        id: "3",
        title: "Ideas",
        content: "New app concept for tracking habits",
        createdAt: Date(),
        updatedAt: Date().addingTimeInterval(-7200)
      )
    ]
    return Entry(date: Date(), notes: sampleNotes)
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchNotes()
    let entry = Entry(date: Date(), notes: notes)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchNotes()

    let entry = Entry(date: Date(), notes: notes)

    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}

struct RecentNotesEntry: TimelineEntry {
  let date: Date
  let notes: [NoteDataModel]
}
