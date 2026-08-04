import SwiftUI

struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(state.controller.isVisible ? "关闭 LaunchPad" : "打开 LaunchPad") {
                state.controller.toggle()
            }
            Divider()
            Button("添加应用…") {
                // M4
            }
            .disabled(true)
            Divider()
            Button("偏好设置…") {
                openSettings()
            }
            Divider()
            Button("退出 LaunchPad") {
                NSApp.terminate(nil)
            }
        }
        .padding(4)
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
