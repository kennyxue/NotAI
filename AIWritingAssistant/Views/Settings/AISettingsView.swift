import SwiftUI

struct AISettingsView: View {
    @State private var openAIApiKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    @State private var googleApiKey: String = UserDefaults.standard.string(forKey: "google_api_key") ?? ""
    @State private var selectedModel: Int = UserDefaults.standard.integer(forKey: "selected_model_index")
    @State private var showsOpenAIApiKey: Bool = false
    @State private var showsGoogleApiKey: Bool = false
    
    private let aiService = AIService.shared
    private let modelOptions = [
        (title: "GPT-3.5 Turbo", type: AIModelType.gpt35),
        (title: "GPT-4", type: AIModelType.gpt4),
        (title: "Google Gemini Pro", type: AIModelType.gemini)
    ]
    
    var body: some View {
        Form {
            Section(header: Text("选择AI模型")) {
                Picker("默认AI模型", selection: $selectedModel) {
                    ForEach(0..<modelOptions.count, id: \.self) { index in
                        Text(modelOptions[index].title).tag(index)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                .onChange(of: selectedModel) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "selected_model_index")
                    
                    // 在真实应用中，这里可能需要通知其他视图模型
                    print("已选择模型: \(modelOptions[newValue].title)")
                }
            }
            
            Section(header: Text("OpenAI API设置")) {
                HStack {
                    if showsOpenAIApiKey {
                        TextField("OpenAI API密钥", text: $openAIApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        SecureField("OpenAI API密钥", text: $openAIApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        showsOpenAIApiKey.toggle()
                    }) {
                        Image(systemName: showsOpenAIApiKey ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Button("保存OpenAI API密钥") {
                    saveOpenAIApiKey()
                }
                .disabled(openAIApiKey.isEmpty)
                
                Text("获取API密钥请访问: [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Google API设置")) {
                HStack {
                    if showsGoogleApiKey {
                        TextField("Google API密钥", text: $googleApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        SecureField("Google API密钥", text: $googleApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        showsGoogleApiKey.toggle()
                    }) {
                        Image(systemName: showsGoogleApiKey ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Button("保存Google API密钥") {
                    saveGoogleApiKey()
                }
                .disabled(googleApiKey.isEmpty)
                
                Text("获取API密钥请访问: [https://ai.google.dev/](https://ai.google.dev/)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("API测试")) {
                Button("测试API连接") {
                    testAPIConnection()
                }
                .disabled(openAIApiKey.isEmpty && googleApiKey.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
    
    private func saveOpenAIApiKey() {
        // 保存到UserDefaults
        UserDefaults.standard.set(openAIApiKey, forKey: "openai_api_key")
        
        // 更新AIService中的密钥
        aiService.setAPIKey(provider: .openAI, key: openAIApiKey)
        
        print("OpenAI API密钥已保存")
    }
    
    private func saveGoogleApiKey() {
        // 保存到UserDefaults
        UserDefaults.standard.set(googleApiKey, forKey: "google_api_key")
        
        // 更新AIService中的密钥
        aiService.setAPIKey(provider: .google, key: googleApiKey)
        
        print("Google API密钥已保存")
    }
    
    private func testAPIConnection() {
        // 根据当前选择的模型类型决定使用哪个API
        let modelType = modelOptions[selectedModel].type
        
        // 创建一个简单的测试消息
        let testMessages = [AIMessage(role: "user", content: "Hello, this is a test message.")]
        
        // 显示测试中的状态
        print("正在测试 \(modelType.provider.rawValue) API连接...")
        
        // 调用AI服务
        aiService.sendMessage(messages: testMessages, model: modelType) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("API测试成功! 响应: \(response)")
                    // 在实际应用中，这里可以显示一个成功的提示
                case .failure(let error):
                    print("API测试失败: \(error.localizedDescription)")
                    // 在实际应用中，这里可以显示一个错误提示
                }
            }
        }
    }
}

#Preview {
    AISettingsView()
        .environmentObject(AppSettings.shared)
} 