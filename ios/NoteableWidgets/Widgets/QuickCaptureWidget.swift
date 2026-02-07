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
      Color.appBackground

      VStack(spacing: 12) {
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 32))
          .foregroundColor(.appAccent)

        Text("Quick Capture")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.appTextPrimary)

        if let recentCount = entry.recentNoteCount, recentCount > 0 {
          Text("\(recentCount) \(recentCount == 1 ? "note" : "notes")")
            .font(.caption2)
            .foregroundColor(.appTextSecondary)
        } else {
          Text("Tap to capture")
            .font(.caption2)
            .foregroundColor(.appTextSecondary)
        }

        Spacer()
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.appSurface)
          .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
      )
      .padding(8)
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
