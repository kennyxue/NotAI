import SwiftUI

class DocumentViewModel: ObservableObject {
    @Published var currentDocument: Document?
    @Published var documents: [Document] = []
    
    func createNewDocument() {
        let newDocument = Document(
            title: "新文档",
            content: "",
            path: "/documents/new"
        )
        documents.append(newDocument)
        currentDocument = newDocument
    }
    
    func openDocument() {
        // TODO: 实现打开文档功能
    }
    
    func saveDocument() {
        guard let document = currentDocument else { return }
        // TODO: 实现保存文档功能
        print("保存文档：\(document.title)")
    }
    
    func updateDocument(content: String) {
        guard var document = currentDocument else { return }
        document.content = content
        document.updatedAt = Date()
        currentDocument = document
        
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
    }
}
