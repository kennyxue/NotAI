import SwiftUI

extension View {
    /// 设置默认窗口大小
    func defaultWindowFrame() -> some View {
        self.frame(
            minWidth: Constants.UI.minWindowWidth,
            idealWidth: Constants.UI.defaultWindowWidth,
            minHeight: Constants.UI.minWindowHeight,
            idealHeight: Constants.UI.defaultWindowHeight
        )
    }
    
    /// 设置侧边栏大小
    func sidebarFrame() -> some View {
        self.frame(
            minWidth: Constants.UI.sidebarMinWidth,
            maxWidth: Constants.UI.sidebarMaxWidth
        )
    }
    
    /// 设置编辑器大小
    func editorFrame() -> some View {
        self.frame(
            minWidth: Constants.UI.editorMinWidth,
            idealWidth: Constants.UI.editorDefaultWidth
        )
    }
    
    /// 设置助手区域大小
    func assistantFrame() -> some View {
        self.frame(
            minWidth: Constants.UI.assistantMinWidth,
            maxWidth: Constants.UI.assistantMaxWidth
        )
    }
    
    /// 设置工具栏项高度
    func toolbarItemFrame() -> some View {
        self.frame(height: Constants.UI.toolbarHeight)
    }
    
    /// 设置标签栏高度
    func tabBarFrame() -> some View {
        self.frame(height: Constants.UI.tabBarHeight)
    }
    
    /// 设置搜索栏高度
    func searchBarFrame() -> some View {
        self.frame(height: Constants.UI.searchBarHeight)
    }
    
    /// 设置消息输入区域高度
    func messageInputFrame() -> some View {
        self.frame(height: Constants.UI.messageInputHeight)
    }
    
    /// 设置目录行高度
    func directoryRowFrame() -> some View {
        self.frame(height: Constants.UI.directoryRowHeight)
    }
} 