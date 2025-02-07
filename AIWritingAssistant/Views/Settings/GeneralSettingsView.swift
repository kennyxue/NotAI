import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    
    var body: some View {
        Form {
            Section("自动保存") {
                Toggle("启用自动保存", isOn: $settings.autoSave)
                if settings.autoSave {
                    Text("文档将在编辑后自动保存")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Section("关于") {
                LabeledContent("版本", value: "1.0.0")
                LabeledContent("构建号", value: "1")
                Link("查看源代码", destination: URL(string: "https://github.com/kennyxue/NotAI")!)
            }
        }
        .padding()
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(AppSettings.shared)
} 