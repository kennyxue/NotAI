import SwiftUI

class DirectoryViewModel: ObservableObject {
    @Published var parentDirectories: [Directory] = []
    @Published var childDirectories: [Directory] = []
    @Published var selectedParentDirectory: Directory?
    @Published var selectedChildDirectory: Directory?
    
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
    private let documentViewModel: DocumentViewModel
    
    // 数据存储服务
    private let dataStore = DataStore.shared
    private let coreDataManager = CoreDataManager.shared
    private var usesCoreData = false  // 控制是否使用Core Data
    
    init(documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        print("初始化DirectoryViewModel")
        loadDirectories()
    }
    
    private func loadDocument(for directory: Directory) {
        if let document = dataStore.getDocument(id: directory.id) {
            // 添加文档内容变更监听
            documentViewModel.onDocumentChanged = { [weak self] updatedDocument in
                print("文档内容已变更，准备保存：\(updatedDocument.title)")
                self?.dataStore.saveDocument(updatedDocument)
            }
            
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
            // 添加文档内容变更监听
            documentViewModel.onDocumentChanged = { [weak self] updatedDocument in
                print("文档内容已变更，准备保存：\(updatedDocument.title)")
                self?.dataStore.saveDocument(updatedDocument)
            }
            
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
        print("开始重命名目录：\(directory.name) -> \(newName)")
        
        // 检查同级目录是否存在同名项
        let hasSameName = directory.isParent
            ? parentDirectories.contains(where: { $0.id != directory.id && $0.name == newName })
            : currentParentDirectory?.children.contains(where: { $0.id != directory.id && $0.name == newName }) ?? false
        
        if hasSameName {
            print("检测到同名目录，自动添加后缀")
            var uniqueName = newName
            var suffix = 1
            while (directory.isParent
                   ? parentDirectories.contains(where: { $0.id != directory.id && $0.name == uniqueName })
                   : currentParentDirectory?.children.contains(where: { $0.id != directory.id && $0.name == uniqueName }) ?? false) {
                suffix += 1
                uniqueName = "\(newName) \(suffix)"
            }
            print("生成唯一名称：\(uniqueName)")
            updateDirectoryName(directory, uniqueName)
        } else {
            updateDirectoryName(directory, newName)
        }
    }
    
    private func updateDirectoryName(_ directory: Directory, _ newName: String) {
        print("更新目录名称：\(directory.name) -> \(newName)")
        
        // 构建新路径
        let newPath = directory.isParent ? "/\(newName)" : "\(currentParentDirectory?.path ?? "")/\(newName)"
        print("新路径：\(newPath)")
        
        // 创建更新后的目录对象，保持ID不变
        let updatedDirectory = Directory(
            id: directory.id,
            name: newName,
            path: newPath,
            isParent: directory.isParent,
            children: directory.children
        )
        
        // 更新目录树
        if directory.isParent {
            if let index = parentDirectories.firstIndex(where: { $0.id == directory.id }) {
                parentDirectories[index] = updatedDirectory
                
                // 如果是当前选中的父目录，更新选中状态
                if currentParentDirectory?.id == directory.id {
                    print("更新当前选中的父目录")
                    currentParentDirectory = updatedDirectory
                }
            }
        } else if let parent = currentParentDirectory {
            var updatedParent = parent
            if let index = updatedParent.children.firstIndex(where: { $0.id == directory.id }) {
                updatedParent.children[index] = updatedDirectory
                
                // 更新父目录
                if let parentIndex = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                    parentDirectories[parentIndex] = updatedParent
                    currentParentDirectory = updatedParent
                }
                
                // 如果是当前选中的子目录，更新选中状态
                if currentChildDirectory?.id == directory.id {
                    print("更新当前选中的子目录")
                    currentChildDirectory = updatedDirectory
                }
            }
        }
        
        // 更新关联的文档标题
        if !directory.isParent {
            print("更新关联文档标题")
            if let document = documentViewModel.currentDocument, document.id == directory.id {
                let updatedDocument = Document(
                    id: document.id,
                    title: newName,
                    content: document.content,
                    path: newPath
                )
                documentViewModel.currentDocument = updatedDocument
                dataStore.saveDocument(updatedDocument)
                print("文档标题已更新：\(updatedDocument.title)")
            }
        }
        
        // 保存到数据存储
        dataStore.saveDirectory(updatedDirectory)
        print("目录重命名完成：\(directory.name) -> \(newName)")
    }
    
    func loadDirectories() {
        print("加载目录...")
        if usesCoreData {
            // 从Core Data加载
            parentDirectories = coreDataManager.fetchDirectories(isParent: true)
                .filter { $0.isParent } // 确保只加载父目录
            print("从Core Data加载了\(parentDirectories.count)个父目录")
        } else {
            // 从DataStore加载
            parentDirectories = dataStore.loadDirectories()
                .filter { $0.isParent } // 确保只加载父目录
            print("从DataStore加载了\(parentDirectories.count)个父目录")
        }
    }
    
    func loadChildren(for directory: Directory) {
        print("加载子目录，父目录：\(directory.name)")
        if usesCoreData {
            // 从Core Data加载子目录
            childDirectories = coreDataManager.fetchDirectories(isParent: false)
                .filter { !$0.isParent && $0.path.hasPrefix(directory.path) } // 确保只加载子目录
            print("从Core Data加载了\(childDirectories.count)个子目录")
        } else {
            // 从DataStore加载子目录
            childDirectories = directory.children
                .filter { !$0.isParent } // 确保只加载子目录
            print("从DataStore加载了\(childDirectories.count)个子目录")
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
    
    func moveDirectory(id: UUID, to target: Directory) {
        print("移动目录，ID: \(id) -> 目标: \(target.name)")
        
        // 找到要移动的目录
        guard let sourceDirectory = findDirectory(id: id) else {
            print("未找到源目录")
            return
        }
        
        // 如果目标是父目录，且源目录是子目录，则将源目录移动到目标目录下
        if target.isParent && !sourceDirectory.isParent {
            // 从原父目录中移除
            if let currentParent = currentParentDirectory {
                var updatedParent = currentParent
                updatedParent.children.removeAll { $0.id == id }
                if let index = parentDirectories.firstIndex(where: { $0.id == currentParent.id }) {
                    parentDirectories[index] = updatedParent
                    currentParentDirectory = updatedParent
                }
            }
            
            // 添加到新父目录
            var updatedTarget = target
            let movedDirectory = Directory(
                id: sourceDirectory.id,
                name: sourceDirectory.name,
                path: "\(target.path)/\(sourceDirectory.name)",
                isParent: false
            )
            updatedTarget.children.append(movedDirectory)
            if let index = parentDirectories.firstIndex(where: { $0.id == target.id }) {
                parentDirectories[index] = updatedTarget
                if currentParentDirectory?.id == target.id {
                    currentParentDirectory = updatedTarget
                }
            }
            
            // 保存更改
            dataStore.saveDirectories(parentDirectories)
            print("目录移动成功")
        } else {
            print("无效的移动操作：目标必须是父目录，源必须是子目录")
        }
    }
    
    func sortDirectories(by option: DirectorySortOption, ascending: Bool) {
        print("排序目录，选项: \(option.rawValue), 升序: \(ascending)")
        
        let sortedDirectories = parentDirectories.sorted { first, second in
            let result: Bool
            switch option {
            case .name:
                result = first.name.localizedCompare(second.name) == .orderedAscending
            case .createdAt:
                result = first.createdAt < second.createdAt
            case .updatedAt:
                result = first.updatedAt < second.updatedAt
            }
            return ascending ? result : !result
        }
        
        parentDirectories = sortedDirectories
        
        // 如果当前选中了父目录，也需要对其子目录进行排序
        if let parent = currentParentDirectory {
            let sortedChildren = parent.children.sorted { first, second in
                let result: Bool
                switch option {
                case .name:
                    result = first.name.localizedCompare(second.name) == .orderedAscending
                case .createdAt:
                    result = first.createdAt < second.createdAt
                case .updatedAt:
                    result = first.updatedAt < second.updatedAt
                }
                return ascending ? result : !result
            }
            
            var updatedParent = parent
            updatedParent.children = sortedChildren
            if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                parentDirectories[index] = updatedParent
                currentParentDirectory = updatedParent
            }
        }
        
        // 保存排序后的目录
        dataStore.saveDirectories(parentDirectories)
        print("目录排序完成")
    }
    
    private func findDirectory(id: UUID) -> Directory? {
        // 在父目录中查找
        if let directory = parentDirectories.first(where: { $0.id == id }) {
            return directory
        }
        
        // 在子目录中查找
        for parent in parentDirectories {
            if let directory = parent.children.first(where: { $0.id == id }) {
                return directory
            }
        }
        
        return nil
    }
}
