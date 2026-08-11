import AppKit
import Combine
import ServiceManagement

@MainActor
final class EasyLaunchPadSettings: ObservableObject {
    @Published var hotkeyKeyCode: UInt32 {
        didSet { EasyLaunchPadStore.saveHotkey(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers) }
    }
    @Published var hotkeyModifiers: UInt32 {
        didSet { EasyLaunchPadStore.saveHotkey(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers) }
    }
    @Published var swipeEnabled: Bool {
        didSet { EasyLaunchPadStore.saveSwipeEnabled(swipeEnabled) }
    }
    @Published var pinchEnabled: Bool {
        didSet { EasyLaunchPadStore.savePinchEnabled(pinchEnabled) }
    }
    @Published var autoStart: Bool {
        didSet { applyAutoStart(autoStart) }
    }
    @Published var iconSize: IconSizeLevel {
        didSet { EasyLaunchPadStore.saveIconSize(iconSize) }
    }
    @Published var iconEntryAnimation: Bool {
        didSet { EasyLaunchPadStore.saveIconEntryAnimation(iconEntryAnimation) }
    }
    @Published var showSystemApps: Bool {
        didSet { EasyLaunchPadStore.saveShowSystemApps(showSystemApps) }
    }
    @Published var autoCheckUpdates: Bool {
        didSet { EasyLaunchPadStore.saveAutoCheckUpdates(autoCheckUpdates) }
    }

    /// Set by AppState when RegisterEventHotKey fails (conflict with another app).
    @Published var hotkeyConflict = false
    /// Set when SMAppService registration fails (e.g. app not in /Applications).
    @Published var autoStartError: String?

    init() {
        hotkeyKeyCode = EasyLaunchPadStore.loadHotkeyKeyCode()
        hotkeyModifiers = EasyLaunchPadStore.loadHotkeyModifiers()
        swipeEnabled = EasyLaunchPadStore.loadSwipeEnabled()
        pinchEnabled = EasyLaunchPadStore.loadPinchEnabled()
        autoStart = EasyLaunchPadStore.loadAutoStart()
        iconSize = EasyLaunchPadStore.loadIconSize()
        iconEntryAnimation = EasyLaunchPadStore.loadIconEntryAnimation()
        showSystemApps = EasyLaunchPadStore.loadShowSystemApps()
        autoCheckUpdates = EasyLaunchPadStore.loadAutoCheckUpdates()
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
        EasyLaunchPadStore.saveAutoStart(enabled)
        autoStartError = nil
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            autoStartError = "自动启动注册失败，请将 EasyLaunchPad 移到 /Applications 后重试"
            if enabled {
                autoStart = false
            }
        }
    }
}
