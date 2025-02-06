import Foundation

protocol DataStoreProtocol {
    func save<T: Encodable>(_ object: T, to file: String) throws
    func load<T: Decodable>(from file: String) throws -> T
    func delete(_ file: String) throws
    func exists(_ file: String) -> Bool
}

class DataStore: DataStoreProtocol {
    static let shared = DataStore()
    private let fileManager = FileManager.default
    
    private init() {}
    
    // 获取文档目录
    private func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 获取文件URL
    private func getFileURL(for file: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(file)
    }
    
    // 保存数据
    func save<T: Encodable>(_ object: T, to file: String) throws {
        let url = getFileURL(for: file)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    // 加载数据
    func load<T: Decodable>(from file: String) throws -> T {
        let url = getFileURL(for: file)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // 删除文件
    func delete(_ file: String) throws {
        let url = getFileURL(for: file)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // 检查文件是否存在
    func exists(_ file: String) -> Bool {
        let url = getFileURL(for: file)
        return fileManager.fileExists(atPath: url.path)
    }
}

// 错误类型
enum DataStoreError: Error {
    case fileNotFound
    case encodingError
    case decodingError
    case saveError
    case deleteError
}

// 文件类型
enum FileType: String {
    case document = ".doc"
    case directory = ".dir"
    case chat = ".chat"
    
    var extension: String {
        return self.rawValue
    }
} 