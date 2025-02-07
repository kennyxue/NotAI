import SwiftUI

struct AssistantView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器
            HStack(spacing: 0) {
                TabButton(title: "CHAT", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                        selectedTab = 0
                    }
                }
                TabButton(title: "COMPOSER", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                        selectedTab = 1
                    }
                }
                TabButton(title: "STYLING", isSelected: selectedTab == 2) {
                    withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                        selectedTab = 2
                    }
                }
            }
            .frame(height: Constants.UI.tabBarHeight)
            .padding(.horizontal, Constants.UI.smallPadding)
            
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
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 聊天历史
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: Constants.UI.mediumPadding) {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(Constants.UI.mediumPadding)
                    .onChange(of: chatViewModel.messages) { _, _ in
                        withAnimation {
                            proxy.scrollTo(chatViewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
            
            Divider()
            
            // 输入区域
            HStack(spacing: Constants.UI.smallPadding) {
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
                        .foregroundColor(messageText.isEmpty || chatViewModel.isProcessing ? .gray : Constants.UI.accentColor)
                }
                .disabled(messageText.isEmpty || chatViewModel.isProcessing)
            }
            .frame(height: Constants.UI.messageInputHeight)
            .padding(Constants.UI.mediumPadding)
            .background(Constants.UI.secondaryBackground)
            .overlay(
                Divider(),
                alignment: .top
            )
        }
    }
}

// Composer 视图
struct ComposerView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing = false
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 对话历史
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: Constants.UI.mediumPadding) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(Constants.UI.mediumPadding)
                    .onChange(of: messages) { _, _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
            
            Divider()
            
            // 工具栏
            HStack(spacing: Constants.UI.mediumPadding) {
                Button(action: {
                    // TODO: 添加提示词模板
                }) {
                    Image(systemName: "text.badge.plus")
                }
                .help("添加提示词模板")
                
                Button(action: {
                    // TODO: 添加历史记录
                }) {
                    Image(systemName: "clock")
                }
                .help("查看历史记录")
                
                Button(action: {
                    // TODO: 添加设置
                }) {
                    Image(systemName: "gear")
                }
                .help("设置")
                
                Spacer()
            }
            .padding(.horizontal, Constants.UI.mediumPadding)
            .padding(.vertical, Constants.UI.smallPadding)
            .background(Constants.UI.secondaryBackground)
            
            // 输入区域
            VStack(spacing: Constants.UI.smallPadding) {
                TextEditor(text: $messageText)
                    .frame(height: Constants.UI.messageInputHeight)
                    .padding(Constants.UI.smallPadding)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.defaultCornerRadius)
                            .stroke(Constants.UI.borderColor, lineWidth: 1)
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
            .padding(Constants.UI.mediumPadding)
            .background(Constants.UI.secondaryBackground)
            .overlay(
                Divider(),
                alignment: .top
            )
        }
    }
}

// Styling 视图
struct StylingView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing = false
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 对话历史
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: Constants.UI.mediumPadding) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(Constants.UI.mediumPadding)
                    .onChange(of: messages) { _, _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
            
            Divider()
            
            // 工具栏
            HStack(spacing: Constants.UI.mediumPadding) {
                Button(action: {
                    // TODO: 添加样式模板
                }) {
                    Image(systemName: "paintbrush")
                }
                .help("添加样式模板")
                
                Button(action: {
                    // TODO: 添加历史记录
                }) {
                    Image(systemName: "clock")
                }
                .help("查看历史记录")
                
                Button(action: {
                    // TODO: 添加设置
                }) {
                    Image(systemName: "gear")
                }
                .help("设置")
                
                Spacer()
            }
            .padding(.horizontal, Constants.UI.mediumPadding)
            .padding(.vertical, Constants.UI.smallPadding)
            .background(Constants.UI.secondaryBackground)
            
            // 输入区域
            VStack(spacing: Constants.UI.smallPadding) {
                TextEditor(text: $messageText)
                    .frame(height: Constants.UI.messageInputHeight)
                    .padding(Constants.UI.smallPadding)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.defaultCornerRadius)
                            .stroke(Constants.UI.borderColor, lineWidth: 1)
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
            .padding(Constants.UI.mediumPadding)
            .background(Constants.UI.secondaryBackground)
            .overlay(
                Divider(),
                alignment: .top
            )
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
                .padding(Constants.UI.mediumPadding)
                .background(
                    RoundedRectangle(cornerRadius: Constants.UI.defaultCornerRadius)
                        .fill(message.isUser ? Constants.UI.accentColor : Constants.UI.hoverBackground)
                )
                .foregroundColor(message.isUser ? .white : .primary)
            
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
