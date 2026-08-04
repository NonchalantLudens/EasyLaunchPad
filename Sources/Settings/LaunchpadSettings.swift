import AppKit
import Combine
import ServiceManagement

@MainActor
final class LaunchpadSettings: ObservableObject {
    @Published var hotkeyKeyCode: UInt32 {
        didSet { LaunchpadStore.saveHotkey(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers) }
    }
    @Published var hotkeyModifiers: UInt32 {
        didSet { LaunchpadStore.saveHotkey(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers) }
    }
    @Published var swipeEnabled: Bool {
        didSet { LaunchpadStore.saveSwipeEnabled(swipeEnabled) }
    }
    @Published var pinchEnabled: Bool {
        didSet { LaunchpadStore.savePinchEnabled(pinchEnabled) }
    }
    @Published var autoStart: Bool {
        didSet { applyAutoStart(autoStart) }
    }

    /// Set by AppState when RegisterEventHotKey fails (conflict with another app).
    @Published var hotkeyConflict = false
    /// Set when SMAppService registration fails (e.g. app not in /Applications).
    @Published var autoStartError: String?

    init() {
        hotkeyKeyCode = LaunchpadStore.loadHotkeyKeyCode()
        hotkeyModifiers = LaunchpadStore.loadHotkeyModifiers()
        swipeEnabled = LaunchpadStore.loadSwipeEnabled()
        pinchEnabled = LaunchpadStore.loadPinchEnabled()
        autoStart = LaunchpadStore.loadAutoStart()
    }

    func autoStartStatusText() -> String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "已启用"
        case .notRegistered:
            return "未开启"
        case .requiresApproval:
            return "需要在系统设置中批准"
        @unknown default:
            return ""
        }
    }

    private func applyAutoStart(_ enabled: Bool) {
        LaunchpadStore.saveAutoStart(enabled)
        autoStartError = nil
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            autoStartError = "自动启动注册失败，请将 LaunchPad 移到 /Applications 后重试"
            if enabled {
                autoStart = false
            }
        }
    }
}
