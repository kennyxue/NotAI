import SwiftUI

struct TextFormatToolbar: View {
    @Binding var selectedColor: Color
    @Binding var isBold: Bool
    @Binding var fontSize: CGFloat
    @Binding var isUnderlined: Bool
    @Binding var isStrikethrough: Bool
    
    let onColorChange: (Color) -> Void
    let onBoldToggle: () -> Void
    let onFontSizeChange: (CGFloat) -> Void
    let onUnderlineToggle: () -> Void
    let onStrikethroughToggle: () -> Void
    
    // 标准颜色选择
    private let standardColors: [[Color]] = [
        [.red, .orange, .yellow, .green, .blue, .purple],
        [Color(red: 0.8, green: 0, blue: 0), 
         Color(red: 0.8, green: 0.4, blue: 0),
         Color(red: 0.8, green: 0.8, blue: 0),
         Color(red: 0, green: 0.6, blue: 0),
         Color(red: 0, green: 0, blue: 0.8),
         Color(red: 0.5, green: 0, blue: 0.5)]
    ]
    
    @State private var showingColorPicker = false
    @State private var showingCustomColorPicker = false
    @State private var showingFontSizeSlider = false
    
    var body: some View {
        HStack(spacing: Constants.UI.smallPadding) {
            // 加粗按钮
            Button(action: onBoldToggle) {
                Image(systemName: "bold")
                    .foregroundColor(isBold ? Constants.UI.accentColor : .primary)
            }
            .help("加粗")
            
            // 下划线按钮
            Button(action: onUnderlineToggle) {
                Image(systemName: "underline")
                    .foregroundColor(isUnderlined ? Constants.UI.accentColor : .primary)
            }
            .help("下划线")
            
            // 删除线按钮
            Button(action: onStrikethroughToggle) {
                Image(systemName: "strikethrough")
                    .foregroundColor(isStrikethrough ? Constants.UI.accentColor : .primary)
            }
            .help("删除线")
            
            Divider()
            
            // 字体大小按钮
            Button {
                showingFontSizeSlider.toggle()
            } label: {
                HStack(spacing: 2) {
                    Text("\(Int(fontSize))")
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
            }
            .help("字体大小")
            .popover(isPresented: $showingFontSizeSlider) {
                FontSizeSlider(
                    fontSize: $fontSize,
                    onSizeChange: onFontSizeChange
                )
            }
            
            Divider()
            
            // 颜色选择按钮
            Button {
                showingColorPicker.toggle()
            } label: {
                HStack(spacing: 2) {
                    Text("A")
                        .foregroundColor(selectedColor)
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                }
            }
            .help("选择文字颜色")
            .popover(isPresented: $showingColorPicker) {
                VStack(spacing: 12) {
                    Text("标准颜色")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    
                    VStack(spacing: 4) {
                        ForEach(standardColors, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(row, id: \.self) { color in
                                    ColorButton(color: color, isSelected: selectedColor == color) {
                                        onColorChange(color)
                                        showingColorPicker = false
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    Button("更多颜色...") {
                        showingColorPicker = false
                        showingCustomColorPicker = true
                    }
                    .font(.system(size: 13))
                    .padding(.bottom, 8)
                }
                .frame(width: 200)
                .background(Color(NSColor.windowBackgroundColor))
            }
            .sheet(isPresented: $showingCustomColorPicker) {
                ColorPickerPanel(
                    isPresented: $showingCustomColorPicker,
                    selectedColor: $selectedColor,
                    onColorSelected: { color in
                        onColorChange(color)
                    }
                )
                .frame(width: 200, height: 250)
            }
        }
        .padding(.horizontal, Constants.UI.smallPadding)
    }
}

// 颜色选择按钮组件
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
                .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(color.isBright ? .black : .white)
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 颜色亮度检测扩展
extension Color {
    var isBright: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return brightness > 0.5
    }
}

#Preview {
    TextFormatToolbar(
        selectedColor: .constant(.black),
        isBold: .constant(false),
        fontSize: .constant(14),
        isUnderlined: .constant(false),
        isStrikethrough: .constant(false),
        onColorChange: { _ in },
        onBoldToggle: { },
        onFontSizeChange: { _ in },
        onUnderlineToggle: { },
        onStrikethroughToggle: { }
    )
} 