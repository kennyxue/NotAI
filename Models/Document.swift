import Foundation

struct Document: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var metadata: [String: String]
    
    init(id: UUID = UUID(), 
         title: String = "新文档", 
         content: String = "", 
         tags: [String] = [], 
         metadata: [String: String] = [:]) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
        self.metadata = metadata
    }
    
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}

// 文档类型枚举
enum DocumentType: String, Codable {
    case text
    case markdown
    case richText
}

// 文档状态枚举
enum DocumentStatus: String, Codable {
    case draft
    case published
    case archived
} 