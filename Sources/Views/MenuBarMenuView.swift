import SwiftUI

struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Button(state.controller.isVisible ? "关闭 EasyLaunchPad" : "打开 EasyLaunchPad") {
            state.controller.toggle()
        }
        Divider()
        SettingsLink {
            Text("偏好设置…")
        }
        Button("关于 EasyLaunchPad…") {
            NSApp.orderFrontStandardAboutPanel(nil)
        }
        Divider()
        Button("退出 EasyLaunchPad") {
            NSApp.terminate(nil)
        }
    }
}
