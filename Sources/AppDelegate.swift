import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var state = AppState()

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        state.controller.show()
        return true
    }
}
