import Foundation
import Combine

class DirectoryViewModel: ObservableObject {
    @Published var parentDirectories: [Directory] = []
    @Published var currentParentDirectory: Directory?
    @Published var currentChildDirectory: Directory?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let fileManager = FileManagerService.shared
    private let documentViewModel: DocumentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        loadRootDirectories()
        setupBindings()
    }
    
    // 设置数据绑定
    private func setupBindings() {
        $currentChildDirectory
            .sink { [weak self] directory in
                if let document = directory?.documents.first {
                    self?.documentViewModel.currentDocument = document
                }
            }
            .store(in: &cancellables)
    }
    
    // 加载根目录
    private func loadRootDirectories() {
        isLoading = true
        
        // 创建示例数据（实际应该从存储加载）
        let documents = Directory(name: "文档")
        let notes = Directory(name: "笔记")
        let drafts = Directory(name: "草稿")
        
        parentDirectories = [documents, notes, drafts]
        isLoading = false
    }
    
    // 创建新目录
    func createDirectory(name: String, parent: Directory? = nil) {
        do {
            let newDirectory = try fileManager.createDirectory(name, parent: parent)
            if let parent = parent {
                if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                    parentDirectories[index].children.append(newDirectory)
                }
            } else {
                parentDirectories.append(newDirectory)
            }
        } catch {
            self.error = error
        }
    }
    
    // 删除目录
    func deleteDirectory(_ directory: Directory) {
        do {
            try fileManager.deleteDirectory(directory)
            if let parent = findParentDirectory(for: directory) {
                if let index = parentDirectories.firstIndex(where: { $0.id == parent.id }) {
                    parentDirectories[index].children.removeAll { $0.id == directory.id }
                }
            } else {
                parentDirectories.removeAll { $0.id == directory.id }
            }
        } catch {
            self.error = error
        }
    }
    
    // 重命名目录
    func renameDirectory(_ directory: Directory, newName: String) {
        var updatedDirectory = directory
        updatedDirectory.name = newName
        
        do {
            try fileManager.saveDirectory(updatedDirectory)
            if let parent = findParentDirectory(for: directory) {
                if let parentIndex = parentDirectories.firstIndex(where: { $0.id == parent.id }),
                   let directoryIndex = parentDirectories[parentIndex].children.firstIndex(where: { $0.id == directory.id }) {
                    parentDirectories[parentIndex].children[directoryIndex] = updatedDirectory
                }
            } else {
                if let index = parentDirectories.firstIndex(where: { $0.id == directory.id }) {
                    parentDirectories[index] = updatedDirectory
                }
            }
        } catch {
            self.error = error
        }
    }
    
    // 查找父目录
    private func findParentDirectory(for directory: Directory) -> Directory? {
        for parent in parentDirectories {
            if parent.children.contains(where: { $0.id == directory.id }) {
                return parent
            }
        }
        return nil
    }
}

// 目录操作错误
enum DirectoryError: Error {
    case createError
    case deleteError
    case renameError
    case notFound
    case invalidOperation
} 