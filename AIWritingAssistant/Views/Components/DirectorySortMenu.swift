import SwiftUI

enum DirectorySortOption: String, CaseIterable {
    case name = "名称"
    case createdAt = "创建时间"
    case updatedAt = "修改时间"
    
    var systemImage: String {
        switch self {
        case .name: return "textformat"
        case .createdAt: return "calendar"
        case .updatedAt: return "clock"
        }
    }
}

struct DirectorySortMenu: View {
    @EnvironmentObject var directoryViewModel: DirectoryViewModel
    @Binding var selectedOption: DirectorySortOption
    @Binding var isAscending: Bool
    
    var body: some View {
        Menu {
            ForEach(DirectorySortOption.allCases, id: \.self) { option in
                Button(action: {
                    if selectedOption == option {
                        isAscending.toggle()
                    } else {
                        selectedOption = option
                    }
                    directoryViewModel.sortDirectories(by: option, ascending: isAscending)
                }) {
                    Label(option.rawValue, systemImage: option.systemImage)
                    if selectedOption == option {
                        Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                    }
                }
            }
        } label: {
            Label("排序", systemImage: "arrow.up.arrow.down")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    DirectorySortMenu(
        selectedOption: .constant(.name),
        isAscending: .constant(true)
    )
    .environmentObject(DirectoryViewModel(documentViewModel: DocumentViewModel()))
} 