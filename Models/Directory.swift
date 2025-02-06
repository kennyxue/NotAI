import Foundation

struct Directory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var children: [Directory]
    var documents: [Document]
    var createdAt: Date
    var updatedAt: Date
    var metadata: [String: String]
    
    init(id: UUID = UUID(),
         name: String,
         children: [Directory] = [],
         documents: [Document] = [],
         metadata: [String: String] = [:]) {
        self.id = id
        self.name = name
        self.children = children
        self.documents = documents
        self.createdAt = Date()
        self.updatedAt = Date()
        self.metadata = metadata
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.id == rhs.id
    }
    
    // 添加文档
    mutating func addDocument(_ document: Document) {
        documents.append(document)
        updatedAt = Date()
    }
    
    // 删除文档
    mutating func removeDocument(id: UUID) {
        documents.removeAll { $0.id == id }
        updatedAt = Date()
    }
    
    // 添加子目录
    mutating func addSubdirectory(_ directory: Directory) {
        children.append(directory)
        updatedAt = Date()
    }
    
    // 删除子目录
    mutating func removeSubdirectory(id: UUID) {
        children.removeAll { $0.id == id }
        updatedAt = Date()
    }
} 