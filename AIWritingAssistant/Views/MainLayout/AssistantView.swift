import SwiftUI

struct AssistantView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器
            HStack(spacing: 0) {
                TabButton(title: "CHAT", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "COMPOSER", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "STYLING", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal)
            
            // 内容区域
            if selectedTab == 0 {
                ChatView()
            } else if selectedTab == 1 {
                ComposerView()
            } else {
                StylingView()
            }
        }
        .background(Constants.UI.secondaryBackground)
    }
}

// 聊天视图
struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var messageText: String = ""
    
    var body: some View {
        VStack {
            // 聊天历史
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // 输入区域
            HStack {
                TextField("输入消息...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(chatViewModel.isProcessing)
                
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    chatViewModel.sendMessage(messageText)
                    messageText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .disabled(messageText.isEmpty || chatViewModel.isProcessing)
            }
            .padding()
        }
    }
}

// Composer 视图
struct ComposerView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            // 对话历史
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // 工具栏
            HStack {
                Button(action: {
                    // TODO: 添加提示词模板
                }) {
                    Image(systemName: "text.badge.plus")
                }
                Button(action: {
                    // TODO: 添加历史记录
                }) {
                    Image(systemName: "clock")
                }
                Button(action: {
                    // TODO: 添加设置
                }) {
                    Image(systemName: "gear")
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // 输入区域
            VStack(spacing: 8) {
                TextEditor(text: $messageText)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                HStack {
                    Spacer()
                    Button("生成") {
                        guard !messageText.isEmpty else { return }
                        // 添加用户消息
                        messages.append(ChatMessage(content: messageText, isUser: true))
                        // TODO: 调用AI生成内容
                        isProcessing = true
                        // 模拟AI响应
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            messages.append(ChatMessage(content: "这是AI生成的内容示例。", isUser: false))
                            messageText = ""
                            isProcessing = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(messageText.isEmpty || isProcessing)
                    
                    Button("清空") {
                        messageText = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(messageText.isEmpty)
                }
            }
            .padding()
        }
    }
}

// Styling 视图
struct StylingView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            // 对话历史
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // 工具栏
            HStack {
                Button(action: {
                    // TODO: 添加样式模板
                }) {
                    Image(systemName: "paintbrush")
                }
                Button(action: {
                    // TODO: 添加历史记录
                }) {
                    Image(systemName: "clock")
                }
                Button(action: {
                    // TODO: 添加设置
                }) {
                    Image(systemName: "gear")
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // 输入区域
            VStack(spacing: 8) {
                TextEditor(text: $messageText)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                HStack {
                    Spacer()
                    Button("优化样式") {
                        guard !messageText.isEmpty else { return }
                        // 添加用户消息
                        messages.append(ChatMessage(content: messageText, isUser: true))
                        // TODO: 调用AI优化样式
                        isProcessing = true
                        // 模拟AI响应
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            messages.append(ChatMessage(content: "这是优化后的样式示例。", isUser: false))
                            messageText = ""
                            isProcessing = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(messageText.isEmpty || isProcessing)
                    
                    Button("清空") {
                        messageText = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(messageText.isEmpty)
                }
            }
            .padding()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Constants.UI.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(10)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    AssistantView()
        .environmentObject(ChatViewModel())
}
