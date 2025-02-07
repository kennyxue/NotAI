import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        }
    }
    
    @Published var systemPrompt: String {
        didSet {
            UserDefaults.standard.set(systemPrompt, forKey: "systemPrompt")
        }
    }
    
    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(Double(fontSize), forKey: "fontSize")
        }
    }
    
    @Published var autoSave: Bool {
        didSet {
            UserDefaults.standard.set(autoSave, forKey: "autoSave")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? Constants.AI.modelName
        self.systemPrompt = UserDefaults.standard.string(forKey: "systemPrompt") ?? "你是一个AI写作助手。"
        self.fontSize = CGFloat(UserDefaults.standard.double(forKey: "fontSize")) > 0 ? 
            CGFloat(UserDefaults.standard.double(forKey: "fontSize")) : Constants.UI.bodyFontSize
        self.autoSave = UserDefaults.standard.bool(forKey: "autoSave")
    }
    
    static let shared = AppSettings()
} 