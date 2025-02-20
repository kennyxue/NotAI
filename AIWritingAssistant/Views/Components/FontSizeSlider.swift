import SwiftUI

struct FontSizeSlider: View {
    @Binding var fontSize: CGFloat
    let onSizeChange: (CGFloat) -> Void
    
    private let minSize: CGFloat = 8
    private let maxSize: CGFloat = 72
    
    var body: some View {
        VStack(spacing: 8) {
            Text("字体大小: \(Int(fontSize))")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                Text("A")
                    .font(.system(size: 12))
                Slider(
                    value: Binding(
                        get: { fontSize },
                        set: { newSize in
                            fontSize = newSize
                            onSizeChange(newSize)
                        }
                    ),
                    in: minSize...maxSize,
                    step: 1
                )
                Text("A")
                    .font(.system(size: 18))
            }
            .padding(.horizontal, 8)
        }
        .padding(8)
        .frame(width: 200)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    FontSizeSlider(
        fontSize: .constant(16),
        onSizeChange: { _ in }
    )
} 