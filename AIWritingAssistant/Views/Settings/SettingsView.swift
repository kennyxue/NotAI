import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ThemeSettingsView()
                .tabItem {
                    Label("外观", systemImage: "paintbrush")
                }
                .tag(0)
            
            AISettingsView()
                .tabItem {
                    Label("AI设置", systemImage: "brain")
                }
                .tag(1)
            
            GeneralSettingsView()
                .tabItem {
                    Label("通用", systemImage: "gear")
                }
                .tag(2)
        }
        .frame(width: 500, height: 300)
        .environmentObject(settings)
    }
}

#Preview {
    SettingsView()
} 