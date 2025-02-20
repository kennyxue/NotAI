import SwiftUI
import AppKit

struct ColorPickerPanel: View {
    @Binding var isPresented: Bool
    @Binding var selectedColor: Color
    let onColorSelected: (Color) -> Void
    
    @State private var pickerColor: Color
    @State private var showNativeColorPicker = false
    
    init(isPresented: Binding<Bool>, selectedColor: Binding<Color>, onColorSelected: @escaping (Color) -> Void) {
        _isPresented = isPresented
        _selectedColor = selectedColor
        self.onColorSelected = onColorSelected
        _pickerColor = State(initialValue: selectedColor.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("自定义颜色")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            // 颜色预览
            RoundedRectangle(cornerRadius: 6)
                .fill(pickerColor)
                .frame(width: 100, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
            
            // 系统调色板按钮
            Button("打开调色板") {
                showNativeColorPicker = true
                NSColorPanel.shared.orderFront(nil)
            }
            .onChange(of: showNativeColorPicker) { _, newValue in
                if !newValue {
                    NSColorPanel.shared.close()
                }
            }
            
            HStack(spacing: 12) {
                // 取消按钮
                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                // 确定按钮
                Button("确定") {
                    onColorSelected(pickerColor)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(16)
        .frame(width: 200)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            setupColorPanel()
        }
        .onDisappear {
            NSColorPanel.shared.close()
        }
    }
    
    private func setupColorPanel() {
        let colorPanel = NSColorPanel.shared
        colorPanel.showsAlpha = false
        colorPanel.setTarget(self)
        colorPanel.color = NSColor(pickerColor)
        
        // 监听颜色变化
        NotificationCenter.default.addObserver(
            forName: NSColorPanel.colorDidChangeNotification,
            object: colorPanel,
            queue: .main
        ) { _ in
            pickerColor = Color(colorPanel.color)
        }
    }
}

#Preview {
    ColorPickerPanel(
        isPresented: .constant(true),
        selectedColor: .constant(.red),
        onColorSelected: { _ in }
    )
} 