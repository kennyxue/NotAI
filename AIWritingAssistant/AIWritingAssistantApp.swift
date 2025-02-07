//
//  AIWritingAssistantApp.swift
//  AIWritingAssistant
//
//  Created by 薛毅华 on 2025/2/6.
//

import SwiftUI

@main
struct AIWritingAssistantApp: App {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var documentViewModel = DocumentViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(documentViewModel)
                .environmentObject(DirectoryViewModel(documentViewModel: documentViewModel))
                .environmentObject(chatViewModel)
                .environmentObject(settings)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
        .commands {
            // 添加菜单命令
            CommandGroup(replacing: .newItem) {
                Button("新建文档") {
                    documentViewModel.createNewDocument()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("打开文档") {
                    documentViewModel.openDocument()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
}
