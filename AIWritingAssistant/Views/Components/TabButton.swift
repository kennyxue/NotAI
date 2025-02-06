import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Constants.UI.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        TabButton(title: "选项1", isSelected: true) {}
        TabButton(title: "选项2", isSelected: false) {}
    }
    .padding()
} 