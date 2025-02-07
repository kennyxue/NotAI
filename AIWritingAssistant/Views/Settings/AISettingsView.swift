import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    private let models = ["gpt-3.5-turbo", "gpt-4"]
    
    var body: some View {
        Form {
            Section("模型选择") {
                Picker("AI模型", selection: $settings.selectedModel) {
                    ForEach(models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            }
            
            Section("系统提示词") {
                TextEditor(text: $settings.systemPrompt)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.smallCornerRadius)
                            .stroke(Constants.UI.borderColor, lineWidth: 1)
                    )
            }
        }
        .padding()
    }
}

#Preview {
    AISettingsView()
        .environmentObject(AppSettings.shared)
} 