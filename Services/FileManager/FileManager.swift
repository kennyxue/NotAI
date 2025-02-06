import Foundation

protocol FileManagerProtocol {
    func createDirectory(_ name: String, parent: Directory?) throws -> Directory
    func createDocument(_ name: String, in directory: Directory) throws -> Document
    func saveDirectory(_ directory: Directory) throws
    func loadDirectory(id: UUID) throws -> Directory
    func deleteDirectory(_ directory: Directory) throws
    func saveDocument(_ document: Document, in directory: Directory) throws
    func loadDocument(id: UUID) throws -> Document
    func deleteDocument(_ document: Document, from directory: Directory) throws
}

class FileManagerService: FileManagerProtocol {
    static let shared = FileManagerService()
    private let dataStore = DataStore.shared
    
    private init() {}
    
    // 创建目录
    func createDirectory(_ name: String, parent: Directory? = nil) throws -> Directory {
        let newDirectory = Directory(name: name)
        if var parent = parent {
            parent.addSubdirectory(newDirectory)
            try saveDirectory(parent)
        }
        try saveDirectory(newDirectory)
        return newDirectory
    }
    
    // 创建文档
    func createDocument(_ name: String, in directory: Directory) throws -> Document {
        var directory = directory
        let document = Document(title: name)
        directory.addDocument(document)
        try saveDirectory(directory)
        try saveDocument(document, in: directory)
        return document
    }
    
    // 保存目录
    func saveDirectory(_ directory: Directory) throws {
        let fileName = "\(directory.id.uuidString)\(FileType.directory.extension)"
        try dataStore.save(directory, to: fileName)
    }
    
    // 加载目录
    func loadDirectory(id: UUID) throws -> Directory {
        let fileName = "\(id.uuidString)\(FileType.directory.extension)"
        return try dataStore.load(from: fileName)
    }
    
    // 删除目录
    func deleteDirectory(_ directory: Directory) throws {
        let fileName = "\(directory.id.uuidString)\(FileType.directory.extension)"
        try dataStore.delete(fileName)
        
        // 递归删除子目录和文档
        for child in directory.children {
            try deleteDirectory(child)
        }
        for document in directory.documents {
            try deleteDocument(document, from: directory)
        }
    }
    
    // 保存文档
    func saveDocument(_ document: Document, in directory: Directory) throws {
        let fileName = "\(document.id.uuidString)\(FileType.document.extension)"
        try dataStore.save(document, to: fileName)
    }
    
    // 加载文档
    func loadDocument(id: UUID) throws -> Document {
        let fileName = "\(id.uuidString)\(FileType.document.extension)"
        return try dataStore.load(from: fileName)
    }
    
    // 删除文档
    func deleteDocument(_ document: Document, from directory: Directory) throws {
        let fileName = "\(document.id.uuidString)\(FileType.document.extension)"
        try dataStore.delete(fileName)
    }
}

// 文件管理错误类型
enum FileManagerError: Error {
    case directoryNotFound
    case documentNotFound
    case createDirectoryError
    case createDocumentError
    case saveError
    case loadError
    case deleteError
    case invalidOperation
} 