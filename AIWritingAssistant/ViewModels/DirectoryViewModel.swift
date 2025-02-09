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
    
    init(documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        loadDirectories()
    }
    
    private func loadDocument(for directory: Directory) {
        // 模拟加载文档
        let document = Document(
            title: directory.name,
            content: "这是 \(directory.name) 的内容。\n\n可以在这里编辑文档。",
            path: directory.path
        )
        documentViewModel.currentDocument = document
    }
    
    func createDirectory(name: String, isParent: Bool) {
        let newDirectory = Directory(name: name, path: "", isParent: isParent)
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
    }
    
    func renameDirectory(_ directory: Directory, newName: String) {
        let updatedDirectory = Directory(id: directory.id, name: newName, path: directory.path, isParent: directory.isParent)
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
    }
    
    private func loadDirectories() {
        // 添加测试数据
        let quickNotes = Directory(name: "快速笔记", path: "/quick_notes", isParent: true)
        let nathan = Directory(name: "nathan", path: "/nathan", isParent: true)
        let projects = Directory(name: "Quick Notes", path: "/projects", isParent: true)
        let prompt = Directory(name: "prompt", path: "/prompt", isParent: true)
        let newArea = Directory(name: "新分区1", path: "/new_area", isParent: true)
        let japan = Directory(name: "日本游", path: "/japan", isParent: true)
        let model = Directory(name: "大模型", path: "/model", isParent: true)
        let mac = Directory(name: "2024_mac_co...", path: "/mac", isParent: true)
        
        var quickNotesWithChildren = quickNotes
        quickNotesWithChildren.children = [
            Directory(name: "How to save time", path: "/quick_notes/time", isParent: false),
            Directory(name: "工作计划", path: "/quick_notes/work", isParent: false),
            Directory(name: "读书笔记", path: "/quick_notes/reading", isParent: false)
        ]
        
        var nathanWithChildren = nathan
        nathanWithChildren.children = [
            Directory(name: "两轮电动车", path: "/nathan/bike", isParent: false),
            Directory(name: "项目规划", path: "/nathan/project", isParent: false)
        ]
        
        var projectsWithChildren = projects
        projectsWithChildren.children = [
            Directory(name: "AI助手开发", path: "/projects/ai", isParent: false),
            Directory(name: "技术调研", path: "/projects/research", isParent: false)
        ]
        
        var promptWithChildren = prompt
        promptWithChildren.children = [
            Directory(name: "AI提示词", path: "/prompt/ai", isParent: false),
            Directory(name: "常用模板", path: "/prompt/templates", isParent: false)
        ]
        
        var japanWithChildren = japan
        japanWithChildren.children = [
            Directory(name: "行程规划", path: "/japan/plan", isParent: false),
            Directory(name: "景点攻略", path: "/japan/spots", isParent: false),
            Directory(name: "美食推荐", path: "/japan/food", isParent: false)
        ]
        
        parentDirectories = [
            quickNotesWithChildren,
            nathanWithChildren,
            projectsWithChildren,
            promptWithChildren,
            newArea,
            japanWithChildren,
            model,
            mac
        ]
    }
    
    private func loadChildren(for parent: Directory) {
        // 模拟从数据源加载子目录
        // 实际应替换为数据存储层的真实调用
        if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
            parentDirectories[index].children = parent.children
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
