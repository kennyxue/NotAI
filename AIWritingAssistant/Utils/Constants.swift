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
        static let minWindowWidth: CGFloat = 1200  // 增加最小窗口宽度以适应所有内容
        static let minWindowHeight: CGFloat = 700  // 增加最小窗口高度
        static let defaultWindowWidth: CGFloat = 1440
        static let defaultWindowHeight: CGFloat = 900
        
        // 侧边栏尺寸
        static let sidebarMinWidth: CGFloat = 180  // 增加最小宽度
        static let sidebarMaxWidth: CGFloat = 280  // 增加最大宽度
        static let assistantMinWidth: CGFloat = 300  // 增加最小宽度
        static let assistantMaxWidth: CGFloat = 400  // 增加最大宽度
        
        // 编辑区域尺寸
        static let editorMinWidth: CGFloat = 500  // 增加最小宽度
        static let editorDefaultWidth: CGFloat = 700
        
        // 分隔线和边距
        static let dividerWidth: CGFloat = 1
        static let defaultPadding: CGFloat = 8
        static let smallPadding: CGFloat = 4
        static let mediumPadding: CGFloat = 12
        static let largePadding: CGFloat = 16
        
        // 圆角
        static let smallCornerRadius: CGFloat = 4
        static let defaultCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 12
        
        // 动画持续时间
        static let defaultAnimationDuration: Double = 0.3
        static let quickAnimationDuration: Double = 0.2
        static let slowAnimationDuration: Double = 0.5
        
        // 颜色
        static let primaryBackground = Color(.windowBackgroundColor)
        static let secondaryBackground = Color(.controlBackgroundColor)
        static let accentColor = Color.blue
        static let borderColor = Color.gray.opacity(0.2)
        static let selectedBackground = Color.blue.opacity(0.1)
        static let hoverBackground = Color.gray.opacity(0.1)
        
        // 字体大小
        static let smallFontSize: CGFloat = 12
        static let bodyFontSize: CGFloat = 14
        static let subtitleFontSize: CGFloat = 16
        static let titleFontSize: CGFloat = 20
        static let largeTitleFontSize: CGFloat = 24
        
        // 布局常量
        static let toolbarHeight: CGFloat = 28
        static let tabBarHeight: CGFloat = 36
        static let searchBarHeight: CGFloat = 36
        static let messageInputHeight: CGFloat = 100
        static let directoryRowHeight: CGFloat = 32
        
        // 阴影
        static let defaultShadowRadius: CGFloat = 3
        static let defaultShadowOpacity: CGFloat = 0.1
        static let defaultShadowOffset = CGSize(width: 0, height: 2)
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
