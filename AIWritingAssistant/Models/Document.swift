import Foundation

struct Document: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var path: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, content: String = "", path: String) {
        self.id = id
        self.title = title
        self.content = content
        self.path = path
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Core Data 转换支持
    init(from entity: DocumentEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.content = entity.content ?? ""
        self.path = entity.path ?? ""
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
    }
    
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}
