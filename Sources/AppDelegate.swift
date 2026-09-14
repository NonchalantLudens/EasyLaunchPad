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
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        AppState.shared.controller.show()
        return true
    }
}
