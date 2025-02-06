import Foundation
import Combine

class DocumentViewModel: ObservableObject {
    @Published var currentDocument: Document?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let fileManager = FileManagerService.shared
    private var autoSaveTimer: Timer?
    private var lastSaveDate: Date?
    private let autoSaveInterval: TimeInterval = 30 // 30秒自动保存一次
    
    init() {
        setupAutoSave()
    }
    
    // 设置自动保存
    private func setupAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            self?.autoSave()
        }
    }
    
    // 自动保存
    private func autoSave() {
        guard let document = currentDocument,
              let lastSave = lastSaveDate,
              Date().timeIntervalSince(lastSave) >= autoSaveInterval else {
            return
        }
        
        saveDocument()
    }
    
    // 创建新文档
    func createNewDocument() {
        currentDocument = Document()
        saveDocument()
    }
    
    // 打开文档
    func openDocument() {
        // TODO: 实现文档打开功能
    }
    
    // 保存文档
    func saveDocument() {
        guard let document = currentDocument else { return }
        
        do {
            if let directory = findDocumentDirectory(document) {
                try fileManager.saveDocument(document, in: directory)
                lastSaveDate = Date()
            }
        } catch {
            self.error = error
        }
    }
    
    // 更新文档内容
    func updateDocument(content: String) {
        guard var document = currentDocument else { return }
        document.content = content
        document.updatedAt = Date()
        currentDocument = document
    }
    
    // 查找文档所在目录
    private func findDocumentDirectory(_ document: Document) -> Directory? {
        // TODO: 实现文档目录查找功能
        return nil
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
}

// 文档操作错误
enum DocumentError: Error {
    case saveError
    case loadError
    case notFound
    case invalidOperation
} 