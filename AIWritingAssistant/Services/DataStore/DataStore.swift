import Foundation

/// 数据存储服务
class DataStore {
    static let shared = DataStore()
    private let fileManager = FileManager.default
    
    // MARK: - 文件路径
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var appDirectory: URL {
        documentsDirectory.appendingPathComponent("AIWritingAssistant", isDirectory: true)
    }
    
    private var directoriesFile: URL {
        appDirectory.appendingPathComponent("directories.json")
    }
    
    private var documentsFile: URL {
        appDirectory.appendingPathComponent("documents.json")
    }
    
    // MARK: - 初始化
    private init() {
        print("初始化DataStore")
        print("应用目录路径：\(appDirectory.path)")
        createDirectoryIfNeeded()
        createDataFilesIfNeeded()
    }
    
    // MARK: - 目录管理
    private func createDirectoryIfNeeded() {
        do {
            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
                print("创建应用目录成功：\(appDirectory.path)")
            } else {
                print("应用目录已存在：\(appDirectory.path)")
            }
        } catch {
            print("创建应用目录失败：\(error.localizedDescription)")
        }
    }
    
    private func createDataFilesIfNeeded() {
        print("检查数据文件...")
        if !fileExists(at: directoriesFile) {
            print("目录数据文件不存在，创建默认数据")
            saveDefaultDirectories()
        } else {
            print("目录数据文件已存在：\(directoriesFile.path)")
            // 检查文件内容
            do {
                let data = try Data(contentsOf: directoriesFile)
                print("目录数据文件大小：\(data.count)字节")
            } catch {
                print("读取目录数据文件失败：\(error.localizedDescription)")
                print("重新创建默认数据")
                saveDefaultDirectories()
            }
        }
        
        if !fileExists(at: documentsFile) {
            print("文档数据文件不存在，创建默认数据")
            saveDefaultDocuments()
        } else {
            print("文档数据文件已存在：\(documentsFile.path)")
            // 检查文件内容
            do {
                let data = try Data(contentsOf: documentsFile)
                print("文档数据文件大小：\(data.count)字节")
            } catch {
                print("读取文档数据文件失败：\(error.localizedDescription)")
                print("重新创建默认数据")
                saveDefaultDocuments()
            }
        }
    }
    
    private func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    // MARK: - 默认数据
    private func saveDefaultDirectories() {
        print("开始创建默认目录数据")
        
        // 创建父目录
        var quickNotes = Directory(
            id: UUID(uuidString: "7887B826-4285-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
            name: "快速笔记",
            path: "/快速笔记",
            isParent: true
        )
        
        var japanTrip = Directory(
            id: UUID(uuidString: "36C73746-1017-4C7A-B3F0-D7B418775B47") ?? UUID(),
            name: "日本游",
            path: "/日本游",
            isParent: true
        )
        
        // 添加子目录
        quickNotes.children = [
            Directory(
                id: UUID(uuidString: "A7C3B946-1234-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
                name: "How to save time",
                path: "/快速笔记/How to save time"
            ),
            Directory(
                id: UUID(uuidString: "B8D4B826-5678-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
                name: "Daily tasks",
                path: "/快速笔记/Daily tasks"
            )
        ]
        
        japanTrip.children = [
            Directory(
                id: UUID(uuidString: "C9E5B826-9012-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
                name: "行程规划",
                path: "/日本游/行程规划"
            ),
            Directory(
                id: UUID(uuidString: "D0F6B826-3456-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
                name: "预算",
                path: "/日本游/预算"
            )
        ]
        
        let directories = [quickNotes, japanTrip]
        saveDirectories(directories)
        print("默认目录数据创建完成")
    }
    
    private func saveDefaultDocuments() {
        print("开始创建默认文档数据")
        var documents: [Document] = []
        
        // 快速笔记的文档
        documents.append(Document(
            id: UUID(uuidString: "E1G7B826-7890-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
            title: "How to save time",
            content: "1. 制定计划\n2. 专注重要任务\n3. 避免分心\n4. 合理休息",
            path: "/快速笔记/How to save time"
        ))
        
        documents.append(Document(
            id: UUID(uuidString: "F2H8B826-1234-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
            title: "Daily tasks",
            content: "- 早晨运动\n- 检查邮件\n- 团队会议\n- 项目开发",
            path: "/快速笔记/Daily tasks"
        ))
        
        // 日本游的文档
        documents.append(Document(
            id: UUID(uuidString: "G3I9B826-5678-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
            title: "行程规划",
            content: "Day 1: 东京\nDay 2: 箱根\nDay 3: 京都\nDay 4: 大阪",
            path: "/日本游/行程规划"
        ))
        
        documents.append(Document(
            id: UUID(uuidString: "H4J0B826-9012-4DC8-B8D4-7AC0B4252A72") ?? UUID(),
            title: "预算",
            content: "机票: ¥5000\n住宿: ¥3000\n交通: ¥2000\n餐饮: ¥2000",
            path: "/日本游/预算"
        ))
        
        saveDocuments(documents)
        print("默认文档数据创建完成")
    }
    
    // MARK: - 数据存储
    func saveDirectories(_ directories: [Directory]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(directories)
            try data.write(to: directoriesFile)
            print("保存目录成功")
        } catch {
            print("保存目录失败：\(error.localizedDescription)")
        }
    }
    
    func saveDocuments(_ documents: [Document]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(documents)
            try data.write(to: documentsFile)
            print("保存文档成功")
        } catch {
            print("保存文档失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 数据读取
    func loadDirectories() -> [Directory] {
        do {
            let data = try Data(contentsOf: directoriesFile)
            print("成功读取目录数据文件，大小：\(data.count)字节")
            let directories = try JSONDecoder().decode([Directory].self, from: data)
            print("成功解码目录数据，共\(directories.count)个父目录")
            return directories
        } catch {
            print("加载目录失败：\(error.localizedDescription)")
            print("错误详情：\(error)")
            // 如果加载失败，创建默认数据
            saveDefaultDirectories()
            return loadDirectories() // 重试加载
        }
    }
    
    func loadDocuments() -> [Document] {
        do {
            let data = try Data(contentsOf: documentsFile)
            let documents = try JSONDecoder().decode([Document].self, from: data)
            print("加载文档成功，共\(documents.count)个文档")
            return documents
        } catch {
            print("加载文档失败：\(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - 单个文档操作
    func saveDocument(_ document: Document) {
        var documents = loadDocuments()
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        saveDocuments(documents)
        print("保存单个文档成功：\(document.title)")
    }
    
    func deleteDocument(id: UUID) {
        var documents = loadDocuments()
        documents.removeAll { $0.id == id }
        saveDocuments(documents)
        print("删除文档成功：\(id)")
    }
    
    func getDocument(id: UUID) -> Document? {
        let documents = loadDocuments()
        let document = documents.first { $0.id == id }
        print("获取文档：\(document?.title ?? "未找到")")
        return document
    }
    
    // MARK: - 目录操作
    func saveDirectory(_ directory: Directory) {
        print("准备保存目录：\(directory.name)")
        
        // 验证目录类型
        if directory.isParent {
            print("验证父目录数据")
            var directories = loadDirectories()
            if let index = directories.firstIndex(where: { $0.id == directory.id }) {
                directories[index] = directory
            } else {
                directories.append(directory)
            }
            saveDirectories(directories)
            print("保存父目录成功：\(directory.name)")
        } else {
            print("验证子目录数据")
            // 确保子目录有正确的父目录
            var directories = loadDirectories()
            if let parentIndex = directories.firstIndex(where: { $0.path == directory.path.components(separatedBy: "/").dropLast().joined(separator: "/") }) {
                var parent = directories[parentIndex]
                if let childIndex = parent.children.firstIndex(where: { $0.id == directory.id }) {
                    parent.children[childIndex] = directory
                } else {
                    parent.children.append(directory)
                }
                directories[parentIndex] = parent
                saveDirectories(directories)
                print("保存子目录成功：\(directory.name)")
            } else {
                print("警告：未找到子目录的父目录，跳过保存")
            }
        }
    }
    
    func deleteDirectory(id: UUID) {
        print("准备删除目录：\(id)")
        var directories = loadDirectories()
        
        // 查找并删除目录
        if let directoryIndex = directories.firstIndex(where: { $0.id == id }) {
            let directory = directories[directoryIndex]
            
            // 如果是父目录，同时删除其所有子目录
            if directory.isParent {
                print("删除父目录及其子目录：\(directory.name)")
                directories.remove(at: directoryIndex)
                
                // 删除关联的文档
                deleteAssociatedDocuments(for: directory)
            } else {
                // 如果是子目录，从父目录中移除
                print("从父目录中删除子目录：\(directory.name)")
                if let parentIndex = directories.firstIndex(where: { $0.path == directory.path.components(separatedBy: "/").dropLast().joined(separator: "/") }) {
                    var parent = directories[parentIndex]
                    parent.children.removeAll { $0.id == id }
                    directories[parentIndex] = parent
                    
                    // 删除关联的文档
                    deleteDocument(id: id)
                }
            }
            
            saveDirectories(directories)
            print("删除目录成功：\(id)")
        } else {
            print("警告：未找到要删除的目录：\(id)")
        }
    }
    
    private func deleteAssociatedDocuments(for directory: Directory) {
        print("删除目录关联的文档：\(directory.name)")
        // 删除当前目录的文档
        deleteDocument(id: directory.id)
        
        // 递归删除子目录的文档
        for child in directory.children {
            deleteAssociatedDocuments(for: child)
        }
    }
    
    func getDirectory(id: UUID) -> Directory? {
        let directories = loadDirectories()
        let directory = directories.first { $0.id == id }
        print("获取目录：\(directory?.name ?? "未找到")")
        return directory
    }
}
