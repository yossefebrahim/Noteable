import WidgetKit
import SwiftUI

struct PinnedNotesWidget: Widget {
  let kind: String = "PinnedNotesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: PinnedNotesProvider()) { entry in
      PinnedNotesWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Pinned Notes")
    .description("View your pinned notes on your home screen")
    .supportedFamilies([.systemLarge])
  }
}

struct PinnedNotesWidgetEntryView: View {
  var entry: PinnedNotesProvider.Entry

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("Pinned Notes")
            .font(.headline)
            .foregroundColor(.white)

          Spacer()

          Image(systemName: "pin.fill")
            .foregroundColor(.white.opacity(0.8))
        }

        if entry.notes.isEmpty {
          VStack(spacing: 8) {
            Image(systemName: "pin.slash")
              .font(.system(size: 32))
              .foregroundColor(.white.opacity(0.6))

            Text("No pinned notes")
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.8))

            Text("Pin important notes to see them here")
              .font(.caption)
              .foregroundColor(.white.opacity(0.7))
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
              ForEach(entry.notes.prefix(6), id: \.id) { note in
                PinnedNoteCard(note: note)
              }

              if entry.notes.count > 6 {
                Text("+ \(entry.notes.count - 6) more pinned notes")
                  .font(.caption2)
                  .foregroundColor(.white.opacity(0.7))
                  .frame(maxWidth: .infinity, alignment: .center)
              }
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

struct PinnedNoteCard: View {
  let note: NoteDataModel

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      Image(systemName: "pin.fill")
        .font(.caption)
        .foregroundColor(.white.opacity(0.7))
        .padding(.top, 2)

      VStack(alignment: .leading, spacing: 3) {
        Text(note.title.isEmpty ? "Untitled" : note.title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .lineLimit(1)

        Text(note.content.isEmpty ? "No content" : note.content)
          .font(.caption)
          .foregroundColor(.white.opacity(0.85))
          .lineLimit(2)
      }

      Spacer()
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 10)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white.opacity(0.15))
    )
  }
}

struct PinnedNotesProvider: TimelineProvider {
  typealias Entry = PinnedNotesEntry

  func placeholder(in context: Context) -> Entry {
    let sampleNotes = [
      NoteDataModel(
        id: "1",
        title: "Project Deadlines",
        content: "Review due Friday, demo on Monday",
        createdAt: Date(),
        updatedAt: Date(),
        isPinned: true
      ),
      NoteDataModel(
        id: "2",
        title: "Meeting Notes",
        content: "Discussed Q1 planning and goals for the team",
        createdAt: Date(),
        updatedAt: Date().addingTimeInterval(-3600),
        isPinned: true
      ),
      NoteDataModel(
        id: "3",
        title: "Ideas",
        content: "New app concept for tracking habits",
        createdAt: Date(),
        updatedAt: Date().addingTimeInterval(-7200),
        isPinned: true
      ),
      NoteDataModel(
        id: "4",
        title: "Shopping List",
        content: "Milk, eggs, bread, coffee",
        createdAt: Date(),
        updatedAt: Date().addingTimeInterval(-86400),
        isPinned: true
      )
    ]
    return Entry(date: Date(), notes: sampleNotes)
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchPinnedNotes()
    let entry = Entry(date: Date(), notes: notes)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchPinnedNotes()

    let entry = Entry(date: Date(), notes: notes)

    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}

struct PinnedNotesEntry: TimelineEntry {
  let date: Date
  let notes: [NoteDataModel]
}
