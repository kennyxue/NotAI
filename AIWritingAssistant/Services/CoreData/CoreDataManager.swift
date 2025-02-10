import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer
    private let dataStore = DataStore.shared
    private let userDefaults = UserDefaults.standard
    private let hasPerformedInitialMigrationKey = "hasPerformedInitialMigration"
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        print("初始化 Core Data Manager...")
        persistentContainer = NSPersistentContainer(name: "AIWritingAssistant")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data加载失败: \(error.localizedDescription)")
                fatalError("无法加载Core Data存储: \(error)")
            }
            print("Core Data存储加载成功: \(description.url?.path ?? "unknown path")")
            
            // 检查是否需要执行初始数据迁移
            if !self.userDefaults.bool(forKey: self.hasPerformedInitialMigrationKey) {
                print("执行初始数据迁移...")
                self.migrateExistingData(from: self.dataStore)
                self.userDefaults.set(true, forKey: self.hasPerformedInitialMigrationKey)
            } else {
                print("已完成初始数据迁移")
            }
        }
        
        // 启用自动合并策略
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        print("Core Data Manager初始化完成")
    }
    
    // MARK: - CRUD Operations
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                print("Core Data保存成功")
            } catch {
                print("Core Data保存失败: \(error)")
                viewContext.rollback()
            }
        }
    }
    
    // MARK: - Migration
    func migrateExistingData(from dataStore: DataStore) {
        print("开始数据迁移...")
        
        // 迁移目录数据
        let directories = dataStore.loadDirectories()
        for directory in directories {
            createDirectory(from: directory)
        }
        
        // 迁移文档数据
        let documents = dataStore.loadDocuments()
        for document in documents {
            createDocument(from: document)
        }
        
        // 保存迁移的数据
        save()
        print("数据迁移完成")
    }
    
    // MARK: - Directory Operations
    func createDirectory(from directory: Directory) {
        let directoryEntity = DirectoryEntity(context: viewContext)
        directoryEntity.id = directory.id
        directoryEntity.name = directory.name
        directoryEntity.path = directory.path
        directoryEntity.isParent = directory.isParent
        directoryEntity.createdAt = directory.createdAt
        directoryEntity.updatedAt = directory.updatedAt
        
        print("创建目录实体: \(directory.name)")
    }
    
    func fetchDirectories(isParent: Bool) -> [Directory] {
        let request = DirectoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isParent == %@", NSNumber(value: isParent))
        
        do {
            let results = try viewContext.fetch(request)
            return results.map { Directory(from: $0) }
        } catch {
            print("获取目录失败: \(error)")
            return []
        }
    }
    
    // MARK: - Document Operations
    func createDocument(from document: Document) {
        let documentEntity = DocumentEntity(context: viewContext)
        documentEntity.id = document.id
        documentEntity.title = document.title
        documentEntity.content = document.content
        documentEntity.path = document.path
        documentEntity.createdAt = document.createdAt
        documentEntity.updatedAt = document.updatedAt
        
        print("创建文档实体: \(document.title)")
    }
    
    func fetchDocuments(for path: String) -> [Document] {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "path BEGINSWITH %@", path)
        
        do {
            let results = try viewContext.fetch(request)
            return results.map { Document(from: $0) }
        } catch {
            print("获取文档失败: \(error)")
            return []
        }
    }
    
    func updateDocument(_ document: Document) {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let existingDocument = results.first {
                existingDocument.title = document.title
                existingDocument.content = document.content
                existingDocument.updatedAt = Date()
                save()
                print("更新文档成功: \(document.title)")
            }
        } catch {
            print("更新文档失败: \(error)")
        }
    }
    
    func deleteDocument(id: UUID) {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let document = results.first {
                viewContext.delete(document)
                save()
                print("删除文档成功: \(document.title ?? "")")
            }
        } catch {
            print("删除文档失败: \(error)")
        }
    }
} 