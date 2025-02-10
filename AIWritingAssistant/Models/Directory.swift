import Foundation

struct Directory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var path: String
    var isParent: Bool
    var children: [Directory]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, path: String, isParent: Bool = false, children: [Directory] = []) {
        self.id = id
        self.name = name
        self.path = path
        self.isParent = isParent
        self.children = children
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Core Data 转换支持
    init(from entity: DirectoryEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.path = entity.path ?? ""
        self.isParent = entity.isParent
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        
        if let childrenSet = entity.children as? Set<DirectoryEntity> {
            self.children = childrenSet.map { Directory(from: $0) }
        } else {
            self.children = []
        }
    }
    
    // 实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.id == rhs.id
    }
}
