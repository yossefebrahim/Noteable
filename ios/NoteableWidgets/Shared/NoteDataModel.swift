import Foundation

struct NoteDataModel: Codable, Identifiable, Equatable {
  let id: String
  var title: String
  var content: String
  let createdAt: Date
  var updatedAt: Date
  var isPinned: Bool

  init(id: String = UUID().uuidString, title: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date(), isPinned: Bool = false) {
    self.id = id
    self.title = title
    self.content = content
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isPinned = isPinned
  }
}
