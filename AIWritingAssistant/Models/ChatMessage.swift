import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
    
    // 实现 Equatable 协议
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}
