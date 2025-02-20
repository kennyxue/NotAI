import Foundation
import SwiftUI

class DocumentViewModel: ObservableObject {
    @Published var currentDocument: Document? {
        didSet {
            if let document = currentDocument {
                onDocumentChanged?(document)
            }
        }
    }
    
    var onDocumentChanged: ((Document) -> Void)?
    
    @Published var documents: [Document] = []
    
    private let dataStore = DataStore.shared
    
    func createNewDocument() {
        print("创建新文档")
        let newDocument = Document(
            title: "新文档",
            content: "",
            path: "/新文档"
        )
        currentDocument = newDocument
        saveDocument()
    }
    
    func loadDocument(_ document: Document) {
        print("加载文档：\(document.title)")
        currentDocument = document
    }
    
    func updateDocument(content: String) {
        print("更新文档内容")
        guard var document = currentDocument else { return }
        document.content = content
        document.updatedAt = Date()
        currentDocument = document
        saveDocument()
    }
    
    func updateAttributedDocument(content: NSAttributedString) {
        print("更新富文本文档内容")
        guard var document = currentDocument else { return }
        
        // 保存纯文本内容
        document.content = content.string
        
        // 保存富文本内容
        do {
            let data = try content.data(
                from: NSRange(location: 0, length: content.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            document.attributedContent = data
        } catch {
            print("Error saving attributed content: \(error)")
        }
        
        document.updatedAt = Date()
        currentDocument = document
        saveDocument()
    }
    
    func saveDocument() {
        print("保存文档")
        guard let document = currentDocument else { return }
        dataStore.saveDocument(document)
    }
    
    func openDocument() {
        // TODO: 实现打开文档功能
    }
    
    func updateContent(_ newContent: String) {
        if var document = currentDocument {
            document.content = newContent
            document.updatedAt = Date()
            currentDocument = document
            print("文档内容已更新：\(document.title)")
        }
    }
}
