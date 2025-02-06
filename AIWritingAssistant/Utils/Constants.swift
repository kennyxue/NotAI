import Foundation
import SwiftUI

enum Constants {
    enum FileManagerConstants {
        static let documentsDirectory = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        static let defaultFileName = "未命名文档"
        static let fileExtension = "aiwrite"
    }
    
    enum UI {
        // 窗口尺寸
        static let minWindowWidth: CGFloat = 1000
        static let minWindowHeight: CGFloat = 600
        
        // 侧边栏尺寸
        static let sidebarMinWidth: CGFloat = 160
        static let sidebarMaxWidth: CGFloat = 240
        static let assistantMinWidth: CGFloat = 260
        static let assistantMaxWidth: CGFloat = 320
        
        // 编辑区域尺寸
        static let editorMinWidth: CGFloat = 400
        
        // 分隔线和边距
        static let dividerWidth: CGFloat = 1
        static let defaultPadding: CGFloat = 8
        
        // 动画持续时间
        static let defaultAnimationDuration: Double = 0.3
        
        // 颜色
        static let primaryBackground = Color(.windowBackgroundColor)
        static let secondaryBackground = Color(.controlBackgroundColor)
        static let accentColor = Color.blue
        
        // 字体大小
        static let titleFontSize: CGFloat = 20
        static let bodyFontSize: CGFloat = 14
        static let captionFontSize: CGFloat = 12
    }
    
    enum AI {
        static let maxTokens = 2048
        static let temperature = 0.7
        static let modelName = "gpt-3.5-turbo"
    }
    
    enum Error {
        static let fileNotFound = "文件未找到"
        static let saveFailed = "保存失败"
        static let loadFailed = "加载失败"
        static let aiError = "AI服务出错"
    }
}
