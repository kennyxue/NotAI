import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    
    var body: some View {
        Form {
            Section("主题") {
                Picker("外观模式", selection: $settings.isDarkMode) {
                    Text("浅色").tag(false)
                    Text("深色").tag(true)
                }
                .pickerStyle(.segmented)
            }
            
            Section("字体") {
                Slider(
                    value: $settings.fontSize,
                    in: 12...20,
                    step: 1
                ) {
                    Text("字体大小")
                } minimumValueLabel: {
                    Text("12")
                } maximumValueLabel: {
                    Text("20")
                }
                
                Text("预览文本")
                    .font(.system(size: settings.fontSize))
            }
        }
        .padding()
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(AppSettings.shared)
} 