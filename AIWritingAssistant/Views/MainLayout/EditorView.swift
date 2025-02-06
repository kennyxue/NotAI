import SwiftUI

struct EditorView: View {
    @EnvironmentObject var documentViewModel: DocumentViewModel
    @State private var content: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 文档标题栏
            if let document = documentViewModel.currentDocument {
                HStack {
                    Text(document.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Constants.UI.secondaryBackground)
            }
            
            // 编辑区域
            if let document = documentViewModel.currentDocument {
                TextEditor(text: Binding(
                    get: { content },
                    set: { newValue in
                        content = newValue
                        documentViewModel.updateDocument(content: newValue)
                    }
                ))
                .font(.system(size: Constants.UI.bodyFontSize))
                .padding()
                .background(Constants.UI.primaryBackground)
                .onChange(of: documentViewModel.currentDocument) { _, newDocument in
                    if let doc = newDocument {
                        content = doc.content
                    }
                }
                .onAppear {
                    content = document.content
                }
            } else {
                VStack {
                    Text("没有打开的文档")
                        .font(.system(size: Constants.UI.titleFontSize))
                        .foregroundColor(.gray)
                    
                    Button("新建文档") {
                        documentViewModel.createNewDocument()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Constants.UI.primaryBackground)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    documentViewModel.saveDocument()
                }) {
                    Label("保存", systemImage: "square.and.arrow.down")
                }
                .disabled(documentViewModel.currentDocument == nil)
            }
        }
    }
}
