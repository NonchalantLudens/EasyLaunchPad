import SwiftUI

struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Button(state.controller.isVisible ? "关闭 LaunchPad" : "打开 LaunchPad") {
            state.controller.toggle()
        }
        Divider()
        SettingsLink {
            Text("偏好设置…")
        }
        Button("关于 LaunchPad…") {
            NSApp.orderFrontStandardAboutPanel(nil)
        }
        Divider()
        Button("退出 LaunchPad") {
            NSApp.terminate(nil)
        }
    }
}
