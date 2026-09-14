import AppKit
import SwiftUI

/// 设置窗口控制器：AppKit 直接持有窗口，与启动器窗口同一模式。
/// 不走 SwiftUI Settings 场景 / SettingsLink——应用未激活（菜单栏面板
/// 为非激活窗口）时它们的窗口无法可靠创建并置前。
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    func show(state: AppState) {
        if window == nil {
            let settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow.title = "EasyLaunchPad 设置"
            settingsWindow.isReleasedWhenClosed = false
            settingsWindow.tabbingMode = .disallowed
            settingsWindow.setFrameAutosaveName("EasyLaunchPadSettings")
            settingsWindow.contentView = NSHostingView(
                rootView: SettingsView()
                    .environmentObject(state)
                    .environmentObject(state.settings)
                    .environmentObject(state.catalog)
                    .environmentObject(state.updateManager)
            )
            window = settingsWindow
        }
        guard let window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        // 兜底：即使激活被系统拒绝也强制置前显示
        window.orderFrontRegardless()
    }
}
