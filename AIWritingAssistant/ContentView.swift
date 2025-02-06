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
    @State private var isShowingLeftSidebar = true
    @State private var isShowingRightSidebar = true

    var body: some View {
        HSplitView {
            // 左侧目录区域
            if isShowingLeftSidebar {
                HStack(spacing: Constants.UI.dividerWidth) {
                    // 父层目录
                    SidebarView(isParent: true)
                        .frame(minWidth: Constants.UI.sidebarMinWidth, maxWidth: Constants.UI.sidebarMaxWidth)
                    
                    Divider()
                    
                    // 子层目录
                    SidebarView(isParent: false)
                        .frame(minWidth: Constants.UI.sidebarMinWidth, maxWidth: Constants.UI.sidebarMaxWidth)
                }
                .frame(minWidth: Constants.UI.sidebarMinWidth * 2 + Constants.UI.dividerWidth,
                       maxWidth: Constants.UI.sidebarMaxWidth * 2 + Constants.UI.dividerWidth)
            }
            
            // 中央编辑区域
            EditorView()
                .frame(minWidth: Constants.UI.editorMinWidth)
                .layoutPriority(1) // 给予编辑区域更高的布局优先级
            
            // 右侧助手区域
            if isShowingRightSidebar {
                AssistantView()
                    .frame(minWidth: Constants.UI.assistantMinWidth, maxWidth: Constants.UI.assistantMaxWidth)
            }
        }
        .frame(minWidth: Constants.UI.minWindowWidth, minHeight: Constants.UI.minWindowHeight)
        .toolbar {
            // 左侧工具组
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    // 公式编辑
                }) {
                    Image(systemName: "function")
                }
                
                Button(action: {
                    // 表格功能
                }) {
                    Image(systemName: "tablecells")
                }
                
                Button(action: {
                    // 笔功能
                }) {
                    Image(systemName: "pencil")
                }
                
                Button(action: {
                    // 马克笔功能
                }) {
                    Image(systemName: "highlighter")
                }
            }
            
            // 右侧工具组
            ToolbarItemGroup(placement: .automatic) {
                Spacer()
                
                // 左侧边栏开关
                Button(action: {
                    withAnimation {
                        isShowingLeftSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.leading")
                }
                
                // 右侧边栏开关
                Button(action: {
                    withAnimation {
                        isShowingRightSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.trailing")
                }
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
