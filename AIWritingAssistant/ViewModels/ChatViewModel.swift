import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    
    func sendMessage(_ content: String) {
        // TODO: 实现发送消息功能
    }
    
    func processAIResponse(_ content: String) {
        // TODO: 实现AI响应处理功能
    }
    
    func clearChat() {
        // TODO: 实现清空聊天功能
    }
    
    private func appendMessage(_ message: ChatMessage) {
        // TODO: 实现添加消息功能
    }
}
