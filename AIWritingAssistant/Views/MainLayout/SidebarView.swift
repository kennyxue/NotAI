import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    @State private var selectedTab = 0
    let isParent: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器（只在父目录视图显示）
            if isParent {
                HStack(spacing: 0) {
                    TabButton(title: "目录", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "搜索", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
            }
            
            // 内容区域
            if selectedTab == 0 {
                DirectoryList(isParent: isParent)
            } else if isParent {
                SearchView()
            }
        }
        .background(Constants.UI.secondaryBackground)
    }
}

// 目录列表视图
struct DirectoryList: View {
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    let isParent: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 1) {
                if isParent {
                    ForEach(directoryViewModel.parentDirectories) { directory in
                        DirectoryRow(directory: directory)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                directoryViewModel.currentParentDirectory = directory
                            }
                            .background(directoryViewModel.currentParentDirectory?.id == directory.id ? 
                                      Constants.UI.accentColor.opacity(0.2) : Color.clear)
                    }
                } else {
                    if let selectedParent = directoryViewModel.currentParentDirectory {
                        ForEach(selectedParent.children) { directory in
                            DirectoryRow(directory: directory)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    directoryViewModel.currentChildDirectory = directory
                                }
                                .background(directoryViewModel.currentChildDirectory?.id == directory.id ? 
                                          Constants.UI.accentColor.opacity(0.2) : Color.clear)
                        }
                    } else {
                        Text("请选择父目录")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }
}

// 搜索视图
struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("搜索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            
            // 搜索结果列表
            List {
                Text("搜索结果将显示在这里")
                    .foregroundColor(.gray)
            }
        }
    }
}

// 目录行视图
struct DirectoryRow: View {
    let directory: Directory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundColor(.accentColor)
            Text(directory.name)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

