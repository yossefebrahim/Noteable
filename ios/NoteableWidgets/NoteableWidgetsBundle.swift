import WidgetKit
import SwiftUI

@main
struct NoteableWidgetsBundle: WidgetBundle {
  var body: some Widget {
    QuickCaptureWidget()
    NoteableWidget()
    RecentNotesWidget()
  }
}
