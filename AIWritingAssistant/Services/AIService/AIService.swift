import Foundation

enum AIServiceError: Error {
    case invalidURL
    case requestFailed(String)
    case responseParsingFailed
    case apiKeyMissing
    case rateLimitExceeded
    case serverError
    case networkError
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的API请求URL"
        case .requestFailed(let message):
            return "请求失败: \(message)"
        case .responseParsingFailed:
            return "响应解析失败"
        case .apiKeyMissing:
            return "缺少API密钥"
        case .rateLimitExceeded:
            return "超出API请求限制"
        case .serverError:
            return "服务器错误"
        case .networkError:
            return "网络连接错误"
        case .unknown(let message):
            return "未知错误: \(message)"
        }
    }
}

enum AIModelType: String {
    case gpt35 = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
    case gemini = "gemini-pro"
    
    var provider: AIProvider {
        switch self {
        case .gpt35, .gpt4:
            return .openAI
        case .gemini:
            return .google
        }
    }
}

enum AIProvider: String {
    case openAI = "OpenAI"
    case google = "Google"
}

struct AIMessage {
    let role: String
    let content: String
}

protocol AIServiceProtocol {
    func sendMessage(messages: [AIMessage], model: AIModelType, completion: @escaping (Result<String, AIServiceError>) -> Void)
    func cancelRequest()
}

class AIService: AIServiceProtocol {
    static let shared = AIService()
    
    private var currentTask: URLSessionDataTask?
    private var openAIApiKey: String?
    private var googleApiKey: String?
    
    private init() {
        // 从应用配置或安全存储中加载API密钥
        loadAPIKeys()
    }
    
    private func loadAPIKeys() {
        // 从UserDefaults或钥匙串加载API密钥
        // 这里仅为示例，实际应用中应该使用更安全的存储方式
        openAIApiKey = UserDefaults.standard.string(forKey: "openai_api_key")
        googleApiKey = UserDefaults.standard.string(forKey: "google_api_key")
        
        print("API密钥加载状态: OpenAI \(openAIApiKey != nil ? "已加载" : "未加载"), Google \(googleApiKey != nil ? "已加载" : "未加载")")
    }
    
    func setAPIKey(provider: AIProvider, key: String) {
        switch provider {
        case .openAI:
            openAIApiKey = key
            UserDefaults.standard.set(key, forKey: "openai_api_key")
        case .google:
            googleApiKey = key
            UserDefaults.standard.set(key, forKey: "google_api_key")
        }
        print("\(provider.rawValue) API密钥已更新")
    }
    
    func sendMessage(messages: [AIMessage], model: AIModelType, completion: @escaping (Result<String, AIServiceError>) -> Void) {
        // 根据不同的AI提供商和模型类型调用不同的API
        switch model.provider {
        case .openAI:
            sendOpenAIRequest(messages: messages, model: model, completion: completion)
        case .google:
            sendGoogleRequest(messages: messages, model: model, completion: completion)
        }
    }
    
    private func sendOpenAIRequest(messages: [AIMessage], model: AIModelType, completion: @escaping (Result<String, AIServiceError>) -> Void) {
        guard let apiKey = openAIApiKey, !apiKey.isEmpty else {
            completion(.failure(.apiKeyMissing))
            return
        }
        
        // OpenAI API实现（示例）
        // 实际实现需要根据OpenAI API文档进行完整实现
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 构建请求体
        let requestMessages = messages.map { ["role": $0.role, "content": $0.content] }
        let requestBody: [String: Any] = [
            "model": model.rawValue,
            "messages": requestMessages,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.requestFailed("请求体序列化失败")))
            return
        }
        
        // 发送请求
        currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError))
                print("网络请求错误: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed("没有返回数据")))
                return
            }
            
            // 解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(.responseParsingFailed))
                }
            } catch {
                completion(.failure(.responseParsingFailed))
                print("响应解析错误: \(error.localizedDescription)")
            }
        }
        
        currentTask?.resume()
    }
    
    private func sendGoogleRequest(messages: [AIMessage], model: AIModelType, completion: @escaping (Result<String, AIServiceError>) -> Void) {
        guard let apiKey = googleApiKey, !apiKey.isEmpty else {
            completion(.failure(.apiKeyMissing))
            return
        }
        
        // Google Gemini API实现（示例）
        // 实际实现需要根据Google API文档进行完整实现
        // 注意：这是一个占位实现，实际的Gemini API可能有不同的端点和参数
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/\(model.rawValue):generateContent?key=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 构建请求体
        let content = messages.map { $0.content }.joined(separator: "\n")
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": content]]]
            ],
            "generationConfig": [
                "temperature": 0.7
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.requestFailed("请求体序列化失败")))
            return
        }
        
        // 发送请求
        currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError))
                print("网络请求错误: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed("没有返回数据")))
                return
            }
            
            // 解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(.responseParsingFailed))
                }
            } catch {
                completion(.failure(.responseParsingFailed))
                print("响应解析错误: \(error.localizedDescription)")
            }
        }
        
        currentTask?.resume()
    }
    
    func cancelRequest() {
        currentTask?.cancel()
        currentTask = nil
        print("已取消当前AI请求")
    }
}
