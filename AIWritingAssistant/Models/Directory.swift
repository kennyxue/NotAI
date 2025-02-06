import Foundation

struct Directory: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var path: String
    var isParent: Bool
    var children: [Directory]
    var documents: [Document]
    
    init(id: UUID = UUID(), name: String, path: String, isParent: Bool = false) {
        self.id = id
        self.name = name
        self.path = path
        self.isParent = isParent
        self.children = []
        self.documents = []
    }
    
    // 实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.id == rhs.id
    }
}
