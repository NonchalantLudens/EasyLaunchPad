import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let state = AppState.shared
        let content = MenuBarMenuView()
            .environmentObject(state)
            .environmentObject(state.controller)
            .environmentObject(state.updateManager)
            .environmentObject(StatusBarPanelController.shared)
        StatusBarPanelController.shared.install(content: NSHostingView(rootView: content))
        // 手动启动时直接呼出启动器；登录自启（autoStart）场景不弹全屏
        if !state.settings.autoStart {
            DispatchQueue.main.async {
                AppState.shared.controller.show()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        AppState.shared.controller.show()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 启动器窗口隐藏后 App 需驻留菜单栏，绝不随窗口关闭而退出
        false
    }
}
