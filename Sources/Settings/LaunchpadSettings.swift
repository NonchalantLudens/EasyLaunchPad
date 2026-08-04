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

    init() {
        hotkeyKeyCode = LaunchpadStore.loadHotkeyKeyCode()
        hotkeyModifiers = LaunchpadStore.loadHotkeyModifiers()
        swipeEnabled = LaunchpadStore.loadSwipeEnabled()
        pinchEnabled = LaunchpadStore.loadPinchEnabled()
        autoStart = LaunchpadStore.loadAutoStart()
    }

    private func applyAutoStart(_ enabled: Bool) {
        LaunchpadStore.saveAutoStart(enabled)
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            if enabled {
                // Registering requires the app to be installed in /Applications.
                autoStart = false
            }
        }
    }
}
