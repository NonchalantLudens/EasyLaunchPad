import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: LaunchpadSettings

    var body: some View {
        Form {
            Section("快捷键") {
                HStack {
                    Text("呼出 / 关闭 LaunchPad")
                    Spacer()
                    HotkeyRecorderView()
                        .environmentObject(settings)
                }
            }
            Section("触控板手势") {
                Toggle("滑动切换页面（两指/三指）", isOn: $settings.swipeEnabled)
                Toggle("捏合关闭", isOn: $settings.pinchEnabled)
                Text("提示：系统保留的四指缩合手势（Mission Control）无法被第三方应用捕获，请使用全局热键或窗口内手势。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("启动") {
                Toggle("登录时自动启动", isOn: $settings.autoStart)
                Text("自动启动需要将 LaunchPad 安装到 /Applications。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 320)
    }
}
