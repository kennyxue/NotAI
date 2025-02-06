import SwiftUI

class DirectoryViewModel: ObservableObject {
    @Published var parentDirectories: [Directory] = []
    @Published var currentParentDirectory: Directory? {
        didSet {
            // 当父目录改变时，清空子目录选择
            if oldValue?.id != currentParentDirectory?.id {
                currentChildDirectory = nil
            }
        }
    }
    @Published var currentChildDirectory: Directory? {
        didSet {
            // 当子目录改变时，加载对应的文档
            if let directory = currentChildDirectory {
                loadDocument(for: directory)
            }
        }
    }
    
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
}
