import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var selectedModel: AIModelType = .gpt35
    
    private let aiService = AIService.shared
    
    init() {
        // 初始化时添加一条欢迎消息
        messages.append(ChatMessage(
            content: "你好！我是AI写作助手，有什么我可以帮助你的？",
            isUser: false
        ))
    }
    
    func sendMessage(_ content: String) {
        guard !content.isEmpty else { return }
        
        // 添加用户消息
        let userMessage = ChatMessage(content: content, isUser: true)
        messages.append(userMessage)
        
        // 标记为处理中
        isProcessing = true
        errorMessage = nil
        
        // 准备发送给AI服务的消息历史
        let aiMessages = prepareMessagesForAIService()
        
        // 调用AI服务
        aiService.sendMessage(messages: aiMessages, model: selectedModel) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let responseContent):
                    // 添加AI响应消息
                    let assistantMessage = ChatMessage(content: responseContent, isUser: false)
                    self?.messages.append(assistantMessage)
                    
                case .failure(let error):
                    // 处理错误
                    self?.errorMessage = error.localizedDescription
                    print("AI服务错误: \(error.localizedDescription)")
                    
                    // 添加错误消息
                    let errorContent = "抱歉，我遇到了一个问题：\(error.localizedDescription)"
                    let errorMessage = ChatMessage(content: errorContent, isUser: false)
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
    
    private func prepareMessagesForAIService() -> [AIMessage] {
        // 转换最近的消息历史为AI服务需要的格式
        // 通常限制消息数量以避免超出上下文限制
        let recentMessages = messages.suffix(10) // 最近10条消息
        
        return recentMessages.map { message in
            AIMessage(
                role: message.isUser ? "user" : "assistant",
                content: message.content
            )
        }
    }
    
    func clearMessages() {
        messages = [ChatMessage(
            content: "你好！我是AI写作助手，有什么我可以帮助你的？",
            isUser: false
        )]
    }
    
    func cancelCurrentRequest() {
        aiService.cancelRequest()
        isProcessing = false
    }
    
    func setModel(_ model: AIModelType) {
        selectedModel = model
        print("AI模型已切换到: \(model.rawValue)")
    }
}
