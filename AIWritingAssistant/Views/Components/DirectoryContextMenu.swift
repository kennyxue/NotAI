import SwiftUI

struct DirectoryContextMenu: View {
    let directory: Directory
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Group {
            Button(action: {
                directoryViewModel.createDirectory(
                    name: "新建\(directory.isParent ? "目录" : "文档")",
                    isParent: directory.isParent
                )
            }) {
                Label("新建\(directory.isParent ? "目录" : "文档")", systemImage: directory.isParent ? "folder.badge.plus" : "doc.badge.plus")
            }
            
            Button(action: {
                // 重命名逻辑在DirectoryItem中处理
            }) {
                Label("重命名", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                showingDeleteAlert = true
            }) {
                Label("删除", systemImage: "trash")
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                directoryViewModel.deleteDirectory(directory)
            }
        } message: {
            Text("确定要删除 \(directory.name) 吗？此操作不可撤销。")
        }
    }
}

#Preview {
    DirectoryContextMenu(directory: Directory(name: "测试目录", path: "/测试目录"))
        .environmentObject(DirectoryViewModel(documentViewModel: DocumentViewModel()))
} 
