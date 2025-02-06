import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let isUser: Bool
    var metadata: [String: String]
    
    init(id: UUID = UUID(),
         content: String,
         isUser: Bool,
         metadata: [String: String] = [:]) {
        self.id = id
        self.content = content
        self.timestamp = Date()
        self.isUser = isUser
        self.metadata = metadata
    }
}

// 消息类型枚举
enum MessageType: String, Codable {
    case text
    case command
    case suggestion
    case error
}

// 会话上下文
struct ChatContext: Codable {
    var messages: [ChatMessage]
    var metadata: [String: String]
    
    init(messages: [ChatMessage] = [], metadata: [String: String] = [:]) {
        self.messages = messages
        self.metadata = metadata
    }
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    func getLastUserMessage() -> ChatMessage? {
        messages.last { $0.isUser }
    }
    
    func getLastAssistantMessage() -> ChatMessage? {
        messages.last { !$0.isUser }
    }
} 