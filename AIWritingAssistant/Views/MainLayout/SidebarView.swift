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
                        withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                            selectedTab = 0
                        }
                    }
                    TabButton(title: "搜索", isSelected: selectedTab == 1) {
                        withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                            selectedTab = 1
                        }
                    }
                }
                .frame(height: Constants.UI.tabBarHeight)
                .padding(.horizontal, Constants.UI.smallPadding)
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
            LazyVStack(alignment: .leading, spacing: Constants.UI.smallPadding) {
                if isParent {
                    ForEach(directoryViewModel.parentDirectories) { directory in
                        DirectoryRow(directory: directory)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                                    directoryViewModel.currentParentDirectory = directory
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: Constants.UI.smallCornerRadius)
                                    .fill(directoryViewModel.currentParentDirectory?.id == directory.id ?
                                          Constants.UI.selectedBackground : Color.clear)
                            )
                            .padding(.horizontal, Constants.UI.smallPadding)
                    }
                } else {
                    if let selectedParent = directoryViewModel.currentParentDirectory {
                        ForEach(selectedParent.children) { directory in
                            DirectoryRow(directory: directory)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                                        directoryViewModel.currentChildDirectory = directory
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: Constants.UI.smallCornerRadius)
                                        .fill(directoryViewModel.currentChildDirectory?.id == directory.id ?
                                              Constants.UI.selectedBackground : Color.clear)
                                )
                                .padding(.horizontal, Constants.UI.smallPadding)
                        }
                    } else {
                        Text("请选择父目录")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(Constants.UI.mediumPadding)
                    }
                }
            }
            .padding(.vertical, Constants.UI.smallPadding)
        }
    }
}

// 搜索视图
struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: Constants.UI.mediumPadding) {
            // 搜索框
            HStack(spacing: Constants.UI.smallPadding) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("搜索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: Constants.UI.searchBarHeight)
            .padding(.horizontal, Constants.UI.mediumPadding)
            
            // 搜索结果列表
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Constants.UI.smallPadding) {
                    if searchText.isEmpty {
                        Text("输入关键词开始搜索")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(Constants.UI.mediumPadding)
                    } else {
                        Text("搜索结果将显示在这里")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(Constants.UI.mediumPadding)
                    }
                }
            }
        }
    }
}

// 目录行视图
struct DirectoryRow: View {
    let directory: Directory
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: Constants.UI.smallPadding) {
            Image(systemName: "folder")
                .foregroundColor(Constants.UI.accentColor)
            Text(directory.name)
                .lineLimit(1)
            Spacer()
        }
        .frame(height: Constants.UI.directoryRowHeight)
        .padding(.horizontal, Constants.UI.smallPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.smallCornerRadius)
                .fill(isHovered ? Constants.UI.hoverBackground : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    SidebarView(isParent: true)
        .environmentObject(DirectoryViewModel(documentViewModel: DocumentViewModel()))
}

