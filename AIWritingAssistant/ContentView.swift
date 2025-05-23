//
//  ContentView.swift
//  AIWritingAssistant
//
//  Created by 薛毅华 on 2025/2/6.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var documentViewModel: DocumentViewModel
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @StateObject private var settings = AppSettings.shared
    @State private var isShowingLeftSidebar = true
    @State private var isShowingRightSidebar = true
    @State private var leftSidebarWidth: CGFloat = Constants.UI.sidebarMinWidth * 2 + Constants.UI.dividerWidth
    @State private var rightSidebarWidth: CGFloat = Constants.UI.assistantMinWidth
    @State private var isShowingSettings = false

    var body: some View {
        HSplitView {
            // 左侧目录区域
            if isShowingLeftSidebar {
                HStack(spacing: Constants.UI.dividerWidth) {
                    // 父层目录
                    SidebarView(isParent: true)
                        .sidebarFrame()
                    
                    Divider()
                        .frame(width: Constants.UI.dividerWidth)
                    
                    // 子层目录
                    SidebarView(isParent: false)
                        .sidebarFrame()
                }
                .frame(width: leftSidebarWidth)
                .animation(.easeInOut(duration: Constants.UI.defaultAnimationDuration), value: leftSidebarWidth)
            }
            
            // 中央编辑区域
            EditorView()
                .editorFrame()
                .layoutPriority(1)
            
            // 右侧助手区域
            if isShowingRightSidebar {
                AssistantView()
                    .frame(width: rightSidebarWidth)
                    .animation(.easeInOut(duration: Constants.UI.defaultAnimationDuration), value: rightSidebarWidth)
            }
        }
        .defaultWindowFrame()
        .toolbar {
            // 左侧工具组
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    // 公式编辑
                }) {
                    Image(systemName: "function")
                        .toolbarItemFrame()
                }
                .help("插入公式")
                
                Button(action: {
                    // 表格功能
                }) {
                    Image(systemName: "tablecells")
                        .toolbarItemFrame()
                }
                .help("插入表格")
                
                Button(action: {
                    // 笔功能
                }) {
                    Image(systemName: "pencil")
                        .toolbarItemFrame()
                }
                .help("手写笔记")
                
                Button(action: {
                    // 马克笔功能
                }) {
                    Image(systemName: "highlighter")
                        .toolbarItemFrame()
                }
                .help("文本高亮")
            }
            
            // 右侧工具组
            ToolbarItemGroup(placement: .automatic) {
                Spacer()
                
                // 设置按钮
                Button(action: {
                    isShowingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                        .toolbarItemFrame()
                }
                .help("设置")
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView()
                }
                
                // 左侧边栏开关
                Button(action: {
                    withAnimation(.easeInOut(duration: Constants.UI.defaultAnimationDuration)) {
                        isShowingLeftSidebar.toggle()
                        if !isShowingLeftSidebar {
                            leftSidebarWidth = 0
                        } else {
                            leftSidebarWidth = Constants.UI.sidebarMinWidth * 2 + Constants.UI.dividerWidth
                        }
                    }
                }) {
                    Image(systemName: isShowingLeftSidebar ? "sidebar.left" : "sidebar.left")
                        .toolbarItemFrame()
                }
                .help(isShowingLeftSidebar ? "隐藏目录" : "显示目录")
                
                // 右侧边栏开关
                Button(action: {
                    withAnimation(.easeInOut(duration: Constants.UI.defaultAnimationDuration)) {
                        isShowingRightSidebar.toggle()
                        if !isShowingRightSidebar {
                            rightSidebarWidth = 0
                        } else {
                            rightSidebarWidth = Constants.UI.assistantMinWidth
                        }
                    }
                }) {
                    Image(systemName: isShowingRightSidebar ? "sidebar.right" : "sidebar.right")
                        .toolbarItemFrame()
                }
                .help(isShowingRightSidebar ? "隐藏助手" : "显示助手")
            }
        }
    }
}

#Preview {
    let documentViewModel = DocumentViewModel()
    let directoryViewModel = DirectoryViewModel(documentViewModel: documentViewModel)
    return ContentView()
        .environmentObject(documentViewModel)
        .environmentObject(directoryViewModel)
        .environmentObject(ChatViewModel())
}
