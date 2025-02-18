import SwiftUI

struct DirectoryItem: View {
    let directory: Directory
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var isEditing = false
    @State private var editingName = ""
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: Constants.UI.smallPadding) {
            // 目录图标
            Image(systemName: directory.isParent ? "folder.fill" : "doc.text")
                .foregroundColor(Constants.UI.accentColor)
            
            // 目录名称/编辑框
            if isEditing {
                TextField("", text: $editingName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        saveNameChange()
                    }
            } else {
                Text(directory.name)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 右侧按钮（仅在悬停时显示）
            if isHovered && !isEditing {
                HStack(spacing: Constants.UI.smallPadding) {
                    Button(action: {
                        startEditing()
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        directoryViewModel.deleteDirectory(directory)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
        .onTapGesture(count: 2) {
            startEditing()
        }
        .contextMenu {
            DirectoryContextMenu(directory: directory)
        }
        .draggable(directory.id.uuidString) {
            Text(directory.name)
        }
        .dropDestination(for: String.self) { items, location in
            guard let droppedId = items.first.flatMap({ UUID(uuidString: $0) }) else { return false }
            directoryViewModel.moveDirectory(id: droppedId, to: directory)
            return true
        }
        .onChange(of: isTextFieldFocused) { _, isFocused in
            if !isFocused && isEditing {
                saveNameChange()
            }
        }
    }
    
    private func startEditing() {
        print("开始编辑目录名称：\(directory.name)")
        editingName = directory.name
        isEditing = true
        isTextFieldFocused = true
    }
    
    private func saveNameChange() {
        print("保存目录名称变更：\(directory.name) -> \(editingName)")
        if !editingName.isEmpty && editingName != directory.name {
            directoryViewModel.renameDirectory(directory, newName: editingName)
        }
        isEditing = false
        isTextFieldFocused = false
    }
}

#Preview {
    DirectoryItem(directory: Directory(name: "测试目录", path: "/测试目录"))
        .environmentObject(DirectoryViewModel(documentViewModel: DocumentViewModel()))
        .frame(width: 200)
        .padding()
} 