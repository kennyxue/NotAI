import SwiftUI

class DirectoryViewModel: ObservableObject {
    @Published var parentDirectories: [Directory] = []
    @Published var currentParentDirectory: Directory? {
        didSet {
            guard oldValue?.id != currentParentDirectory?.id else { return }
            print("父目录变更: \(oldValue?.name ?? "nil") -> \(currentParentDirectory?.name ?? "nil")")
            
            // 如果是由子目录选择触发的父目录变更，不要清空子目录
            if !isChildDirectorySelecting {
                print("由父目录直接选择触发")
                selectedChildId = nil
                currentChildDirectory = nil
                print("清空子目录选择(由父目录变更触发)")
            } else {
                print("由子目录选择触发父目录变更，保持子目录选择")
            }
            
            // 加载子目录
            loadChildrenIfNeeded()
        }
    }
    
    @Published var currentChildDirectory: Directory? {
        didSet {
            guard currentChildDirectory?.id != oldValue?.id else { return }
            
            if currentChildDirectory == nil { 
                print("子目录被清空")
                selectedChildId = nil
                return 
            }
            
            print("子目录变更: \(oldValue?.name ?? "nil") -> \(currentChildDirectory?.name ?? "nil")")
            
            // 保存当前选择的子目录ID
            selectedChildId = currentChildDirectory?.id
            
            // 加载文档
            loadDocumentIfNeeded()
        }
    }
    
    // 标记是否是由子目录选择触发的状态变更
    private var isChildDirectorySelecting = false
    
    // 保存选中的子目录ID
    private var selectedChildId: UUID?
    
    // 注入文档视图模型
    private var documentViewModel: DocumentViewModel
    
    // 数据存储服务
    private let dataStore = DataStore.shared
    
    init(documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        loadDirectories()
    }
    
    private func loadDocument(for directory: Directory) {
        if let document = dataStore.getDocument(id: directory.id) {
            documentViewModel.currentDocument = document
            print("加载文档成功：\(document.title)")
        } else {
            print("未找到文档：\(directory.name)")
            // 创建新文档
            let document = Document(
                id: directory.id,
                title: directory.name,
                content: "",
                path: directory.path
            )
            dataStore.saveDocument(document)
            documentViewModel.currentDocument = document
            print("创建新文档：\(document.title)")
        }
    }
    
    func createDirectory(name: String, isParent: Bool) {
        let path = isParent ? "/\(name)" : "\(currentParentDirectory?.path ?? "")/\(name)"
        let newDirectory = Directory(name: name, path: path, isParent: isParent)
        
        if isParent {
            parentDirectories.append(newDirectory)
        } else if let parent = currentParentDirectory {
            var updatedParent = parent
            updatedParent.children.append(newDirectory)
            if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                parentDirectories[index] = updatedParent
                currentParentDirectory = updatedParent
            }
        }
        
        // 保存到数据存储
        dataStore.saveDirectory(newDirectory)
        print("创建目录成功：\(newDirectory.name)")
    }
    
    func deleteDirectory(_ directory: Directory) {
        if directory.isParent {
            parentDirectories.removeAll { $0.id == directory.id }
            if currentParentDirectory?.id == directory.id {
                currentParentDirectory = nil
                currentChildDirectory = nil
            }
        } else if let parent = currentParentDirectory {
            var updatedParent = parent
            updatedParent.children.removeAll { $0.id == directory.id }
            if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                parentDirectories[index] = updatedParent
                currentParentDirectory = updatedParent
            }
            if currentChildDirectory?.id == directory.id {
                currentChildDirectory = nil
            }
        }
        
        // 从数据存储中删除
        dataStore.deleteDirectory(id: directory.id)
        print("删除目录成功：\(directory.name)")
    }
    
    func renameDirectory(_ directory: Directory, newName: String) {
        let path = directory.isParent ? "/\(newName)" : "\(currentParentDirectory?.path ?? "")/\(newName)"
        let updatedDirectory = Directory(id: directory.id, name: newName, path: path, isParent: directory.isParent)
        
        if directory.isParent {
            if let index = parentDirectories.firstIndex(where: { $0.id == directory.id }) {
                parentDirectories[index] = updatedDirectory
                if currentParentDirectory?.id == directory.id {
                    currentParentDirectory = updatedDirectory
                }
            }
        } else if let parent = currentParentDirectory {
            var updatedParent = parent
            if let index = updatedParent.children.firstIndex(where: { $0.id == directory.id }) {
                updatedParent.children[index] = updatedDirectory
                if let parentIndex = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                    parentDirectories[parentIndex] = updatedParent
                    currentParentDirectory = updatedParent
                }
                if currentChildDirectory?.id == directory.id {
                    currentChildDirectory = updatedDirectory
                }
            }
        }
        
        // 保存到数据存储
        dataStore.saveDirectory(updatedDirectory)
        print("重命名目录成功：\(directory.name) -> \(newName)")
    }
    
    private func loadDirectories() {
        // 从数据存储加载目录
        parentDirectories = dataStore.loadDirectories()
        print("加载目录成功，共\(parentDirectories.count)个父目录")
    }
    
    private func loadChildren(for parent: Directory) {
        // 从数据存储加载子目录
        if let directory = dataStore.getDirectory(id: parent.id) {
            if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                parentDirectories[index].children = directory.children
                print("加载子目录成功：\(directory.name)，共\(directory.children.count)个子目录")
            }
        }
    }
    
    private func updateParentIfNeeded() {
        guard let child = currentChildDirectory,
              let parent = parentDirectories.first(where: { $0.children.contains(where: { $0.id == child.id }) })
        else { 
            print("无法找到子目录对应的父目录")
            return 
        }
        
        print("检查父目录: \(parent.name)")
        
        // 只在父目录不同时更新
        if currentParentDirectory?.id != parent.id {
            print("更新父目录选择: \(parent.name)")
            currentParentDirectory = parent
        }
    }
    
    private func loadChildrenIfNeeded() {
        if let parent = currentParentDirectory {
            loadChildren(for: parent)
            
            // 如果有已选择的子目录,尝试恢复选择
            if let childId = selectedChildId,
               let child = parent.children.first(where: { $0.id == childId }),
               currentChildDirectory?.id != childId { // 避免重复设置
                print("恢复子目录选择: \(child.name)")
                currentChildDirectory = child
            }
        }
    }
    
    private func loadDocumentIfNeeded() {
        if let directory = currentChildDirectory {
            loadDocument(for: directory)
        }
    }
    
    func selectParentDirectory(_ directory: Directory) {
        print("选择父目录: \(directory.name)")
        guard currentParentDirectory?.id != directory.id else { return }
        
        // 更新父目录
        currentParentDirectory = directory
    }
    
    func selectChildDirectory(_ directory: Directory) {
        print("选择子目录: \(directory.name)")
        
        // 直接加载文档，不改变子目录状态
        loadDocument(for: directory)
    }
}
