import SwiftUI

@main
struct EasyLaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let state = AppState.shared

    var body: some Scene {
        // 设置窗口由 SettingsWindowController（AppKit）直接持有，
        // 不声明 Settings 场景：应用未激活时其窗口无法可靠弹出
        Window("EasyLaunchPad", id: "ghost") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
    }
}
