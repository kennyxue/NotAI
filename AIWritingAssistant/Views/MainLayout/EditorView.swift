import SwiftUI

struct EditorView: View {
    @EnvironmentObject var documentViewModel: DocumentViewModel
    @State private var content: NSAttributedString = NSAttributedString(string: "")
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var selectedColor: Color = .black
    @State private var isBold: Bool = false
    @State private var fontSize: CGFloat = 14
    @State private var isUnderlined: Bool = false
    @State private var isStrikethrough: Bool = false
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
                
                // 格式工具栏
                TextFormatToolbar(
                    selectedColor: $selectedColor,
                    isBold: $isBold,
                    fontSize: $fontSize,
                    isUnderlined: $isUnderlined,
                    isStrikethrough: $isStrikethrough,
                    onColorChange: { color in
                        applyTextColor(color)
                    },
                    onBoldToggle: {
                        toggleBold()
                    },
                    onFontSizeChange: { size in
                        applyFontSize(size)
                    },
                    onUnderlineToggle: {
                        toggleUnderline()
                    },
                    onStrikethroughToggle: {
                        toggleStrikethrough()
                    }
                )
                .frame(height: Constants.UI.toolbarHeight)
                .background(Constants.UI.secondaryBackground)
                .overlay(
                    Divider().opacity(0.5),
                    alignment: .bottom
                )
            }
            
            // 编辑区域
            if let document = documentViewModel.currentDocument {
                NSAttributedTextEditor(
                    attributedText: Binding(
                        get: { content },
                        set: { newValue in
                            content = newValue
                            documentViewModel.updateAttributedDocument(content: newValue)
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
                    ),
                    selectedRange: $selectedRange
                )
                .font(.system(size: Constants.UI.bodyFontSize))
                .padding(Constants.UI.mediumPadding)
                .background(Constants.UI.primaryBackground)
                .onChange(of: documentViewModel.currentDocument) { _, newDocument in
                    if let doc = newDocument {
                        if let attributedContent = doc.attributedContent {
                            do {
                                content = try NSAttributedString(data: attributedContent, 
                                    options: [.documentType: NSAttributedString.DocumentType.rtf], 
                                    documentAttributes: nil)
                            } catch {
                                print("Error loading attributed content: \(error)")
                                content = NSAttributedString(string: doc.content)
                            }
                        } else {
                            content = NSAttributedString(string: doc.content)
                        }
                    }
                }
                .onAppear {
                    if let attributedContent = document.attributedContent {
                        do {
                            content = try NSAttributedString(data: attributedContent, 
                                options: [.documentType: NSAttributedString.DocumentType.rtf], 
                                documentAttributes: nil)
                        } catch {
                            print("Error loading attributed content: \(error)")
                            content = NSAttributedString(string: document.content)
                        }
                    } else {
                        content = NSAttributedString(string: document.content)
                    }
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
    
    private func applyTextColor(_ color: Color) {
        guard selectedRange.length > 0 else { return }
        
        let mutableContent = NSMutableAttributedString(attributedString: content)
        let nsColor = NSColor(color)
        mutableContent.addAttribute(.foregroundColor, value: nsColor, range: selectedRange)
        content = mutableContent
        documentViewModel.updateAttributedDocument(content: content)
    }
    
    private func toggleBold() {
        guard selectedRange.length > 0 else { return }
        
        let mutableContent = NSMutableAttributedString(attributedString: content)
        let fontManager = NSFontManager.shared
        
        mutableContent.enumerateAttribute(.font, in: selectedRange) { value, range, _ in
            if let oldFont = value as? NSFont {
                let newFont: NSFont
                if isBold {
                    newFont = fontManager.convert(oldFont, toNotHaveTrait: .boldFontMask)
                } else {
                    newFont = fontManager.convert(oldFont, toHaveTrait: .boldFontMask)
                }
                mutableContent.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        isBold.toggle()
        content = mutableContent
        documentViewModel.updateAttributedDocument(content: content)
    }
    
    private func applyFontSize(_ size: CGFloat) {
        print("应用字体大小: \(size)")
        guard selectedRange.length > 0 else { return }
        
        let mutableContent = NSMutableAttributedString(attributedString: content)
        mutableContent.enumerateAttribute(.font, in: selectedRange) { value, range, _ in
            if let oldFont = value as? NSFont {
                let newFont = NSFont(descriptor: oldFont.fontDescriptor, size: size)
                mutableContent.addAttribute(.font, value: newFont ?? oldFont, range: range)
            } else {
                let newFont = NSFont.systemFont(ofSize: size)
                mutableContent.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        content = mutableContent
        documentViewModel.updateAttributedDocument(content: content)
    }
    
    private func toggleUnderline() {
        print("切换下划线状态")
        guard selectedRange.length > 0 else { return }
        
        let mutableContent = NSMutableAttributedString(attributedString: content)
        let underlineStyle: Int = isUnderlined ? 0 : NSUnderlineStyle.single.rawValue
        mutableContent.addAttribute(.underlineStyle, value: underlineStyle, range: selectedRange)
        
        content = mutableContent
        documentViewModel.updateAttributedDocument(content: content)
    }
    
    private func toggleStrikethrough() {
        print("切换删除线状态")
        guard selectedRange.length > 0 else { return }
        
        let mutableContent = NSMutableAttributedString(attributedString: content)
        let strikethroughStyle: Int = isStrikethrough ? 0 : NSUnderlineStyle.single.rawValue
        mutableContent.addAttribute(.strikethroughStyle, value: strikethroughStyle, range: selectedRange)
        
        content = mutableContent
        documentViewModel.updateAttributedDocument(content: content)
    }
}

// NSAttributedTextEditor 用于支持富文本编辑
struct NSAttributedTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        print("更新文本视图，当前选择范围: \(selectedRange)")
        let currentRange = nsView.selectedRange()
        if nsView.attributedString() != attributedText {
            // 保存当前滚动位置
            let savedOffset = nsView.enclosingScrollView?.contentView.bounds.origin ?? .zero
            
            // 更新文本内容
            nsView.textStorage?.beginEditing()
            nsView.textStorage?.setAttributedString(attributedText)
            nsView.textStorage?.endEditing()
            
            // 恢复滚动位置
            nsView.enclosingScrollView?.contentView.scroll(to: savedOffset)
            
            // 恢复选择范围
            if selectedRange.location != NSNotFound && selectedRange.length > 0 {
                print("恢复选择范围: \(selectedRange)")
                nsView.setSelectedRange(selectedRange)
            } else if currentRange.location != NSNotFound && currentRange.length > 0 {
                print("保持当前选择范围: \(currentRange)")
                selectedRange = currentRange
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NSAttributedTextEditor
        
        init(_ parent: NSAttributedTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let currentRange = textView.selectedRange()
            parent.attributedText = textView.attributedString()
            
            // 确保在文本变化后保持选择范围
            if currentRange.location != NSNotFound {
                print("文本变化后保持选择范围: \(currentRange)")
                DispatchQueue.main.async {
                    textView.setSelectedRange(currentRange)
                    self.parent.selectedRange = currentRange
                }
            }
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let newRange = textView.selectedRange()
            if newRange.location != NSNotFound {
                print("选择范围变化: \(newRange)")
                parent.selectedRange = newRange
            }
        }
    }
}

#Preview {
    EditorView()
        .environmentObject(DocumentViewModel())
}
