import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var error: Error?
    @Published var currentMessage: String = ""
    
    private let dataStore = DataStore.shared
    private var context = ChatContext()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadChat()
        setupErrorHandling()
    }
    
    private func setupErrorHandling() {
        $error
            .compactMap { $0 }
            .sink { [weak self] error in
                // 处理错误，可以显示给用户
                print("Chat error: \(error)")
                self?.isProcessing = false
            }
            .store(in: &cancellables)
    }
    
    // 发送消息
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: content, isUser: true)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messages.append(userMessage)
            self.context.addMessage(userMessage)
            self.currentMessage = ""
            self.isProcessing = true
            
            // 保存当前状态
            self.saveChat()
            
            // 模拟AI响应
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let aiMessage = ChatMessage(
                    content: "这是AI的回复示例。实际开发中需要集成OpenAI API。",
                    isUser: false
                )
                self.messages.append(aiMessage)
                self.context.addMessage(aiMessage)
                self.isProcessing = false
                
                // 保存更新后的状态
                self.saveChat()
            }
        }
    }
    
    // 清空聊天记录
    func clearChat() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messages.removeAll()
            self.context = ChatContext()
            self.saveChat()
        }
    }
    
    // 保存聊天记录
    private func saveChat() {
        do {
            try dataStore.save(context, to: "chat_history\(FileType.chat.extension)")
        } catch {
            self.error = error
        }
    }
    
    // 加载聊天记录
    func loadChat() {
        do {
            if dataStore.exists("chat_history\(FileType.chat.extension)") {
                context = try dataStore.load(from: "chat_history\(FileType.chat.extension)")
                DispatchQueue.main.async { [weak self] in
                    self?.messages = self?.context.messages ?? []
                }
            }
        } catch {
            self.error = error
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// 聊天错误类型
enum ChatError: Error {
    case sendError
    case receiveError
    case saveError
    case loadError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .sendError:
            return "发送消息失败"
        case .receiveError:
            return "接收消息失败"
        case .saveError:
            return "保存聊天记录失败"
        case .loadError:
            return "加载聊天记录失败"
        case .networkError:
            return "网络连接失败"
        }
    }
} 