import SwiftUI

struct GestureSettingsView: View {
    @EnvironmentObject private var settings: LaunchpadSettings

    var body: some View {
        Form {
            Section("触控板手势") {
                Toggle("滑动切换页面（两指/三指）", isOn: $settings.swipeEnabled)
                Toggle("捏合关闭", isOn: $settings.pinchEnabled)
                Text("提示：系统保留的四指缩合手势（Mission Control）无法被第三方应用捕获，请使用全局热键或窗口内手势。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
