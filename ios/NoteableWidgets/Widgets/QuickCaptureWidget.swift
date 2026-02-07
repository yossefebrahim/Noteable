import WidgetKit
import SwiftUI

struct QuickCaptureWidget: Widget {
  let kind: String = "QuickCaptureWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: QuickCaptureProvider()) { entry in
      QuickCaptureWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Quick Capture")
    .description("Instantly capture notes with a single tap")
    .supportedFamilies([.systemSmall])
  }
}

struct QuickCaptureWidgetEntryView: View {
  var entry: QuickCaptureProvider.Entry

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.red.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(spacing: 12) {
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 32))
          .foregroundColor(.white)

        Text("Quick Capture")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.white)

        if let recentCount = entry.recentNoteCount, recentCount > 0 {
          Text("\(recentCount) \(recentCount == 1 ? "note" : "notes")")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.9))
        } else {
          Text("Tap to capture")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.8))
        }

        Spacer()
      }
      .padding()
    }
    .widgetURL(URL(string: "noteable://quick-capture"))
  }
}

struct QuickCaptureProvider: TimelineProvider {
  typealias Entry = QuickCaptureEntry

  func placeholder(in context: Context) -> Entry {
    Entry(date: Date(), recentNoteCount: 3)
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchNotes()
    let entry = Entry(date: Date(), recentNoteCount: notes.count)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let dataStore = WidgetDataStore.shared
    let notes = dataStore.fetchNotes()

    let entry = Entry(date: Date(), recentNoteCount: notes.count)

    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}

struct QuickCaptureEntry: TimelineEntry {
  let date: Date
  let recentNoteCount: Int?
}
