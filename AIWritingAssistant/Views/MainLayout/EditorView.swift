import SwiftUI

struct EditorView: View {
    @EnvironmentObject var documentViewModel: DocumentViewModel
    @State private var content: String = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 文档标题栏
            if let document = documentViewModel.currentDocument {
                HStack(spacing: Constants.UI.mediumPadding) {
                    Image(systemName: "doc.text")
                        .foregroundColor(Constants.UI.accentColor)
                    Text(document.title)
                        .font(.system(size: Constants.UI.subtitleFontSize, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    
                    // 编辑状态指示器
                    if isEditing {
                        Text("编辑中...")
                            .font(.system(size: Constants.UI.smallFontSize))
                            .foregroundColor(.gray)
                            .transition(.opacity)
                    }
                }
                .frame(height: Constants.UI.toolbarHeight)
                .padding(.horizontal, Constants.UI.mediumPadding)
                .background(Constants.UI.secondaryBackground)
                .overlay(
                    Divider().opacity(0.5),
                    alignment: .bottom
                )
            }
            
            // 编辑区域
            if let document = documentViewModel.currentDocument {
                TextEditor(text: Binding(
                    get: { content },
                    set: { newValue in
                        content = newValue
                        documentViewModel.updateDocument(content: newValue)
                        withAnimation {
                            isEditing = true
                        }
                        // 延迟隐藏编辑状态
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                isEditing = false
                            }
                        }
                    }
                ))
                .font(.system(size: Constants.UI.bodyFontSize))
                .padding(Constants.UI.mediumPadding)
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
                VStack(spacing: Constants.UI.mediumPadding) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: Constants.UI.largeTitleFontSize))
                        .foregroundColor(.gray)
                    
                    Text("没有打开的文档")
                        .font(.system(size: Constants.UI.titleFontSize))
                        .foregroundColor(.gray)
                    
                    Button("新建文档") {
                        withAnimation {
                            documentViewModel.createNewDocument()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
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
                .help("保存文档")
                
                Button(action: {
                    // 导出功能
                }) {
                    Label("导出", systemImage: "square.and.arrow.up")
                }
                .disabled(documentViewModel.currentDocument == nil)
                .help("导出文档")
                
                Button(action: {
                    // 打印功能
                }) {
                    Label("打印", systemImage: "printer")
                }
                .disabled(documentViewModel.currentDocument == nil)
                .help("打印文档")
            }
        }
    }
}

#Preview {
    EditorView()
        .environmentObject(DocumentViewModel())
}
