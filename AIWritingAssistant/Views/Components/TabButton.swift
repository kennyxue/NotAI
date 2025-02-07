import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Constants.UI.bodyFontSize, weight: isSelected ? .medium : .regular))
                .frame(maxWidth: .infinity)
                .frame(height: Constants.UI.tabBarHeight)
                .background(
                    ZStack {
                        if isSelected {
                            Constants.UI.accentColor
                        } else if isHovered {
                            Constants.UI.hoverBackground
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: Constants.UI.quickAnimationDuration)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    HStack(spacing: 0) {
        TabButton(title: "选项1", isSelected: true) {}
        TabButton(title: "选项2", isSelected: false) {}
    }
    .padding()
    .frame(width: 300)
} 