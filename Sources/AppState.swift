import AppKit
import Carbon.HIToolbox
import Combine

@MainActor
final class AppState: ObservableObject {
    let controller = LaunchPadController()
    let catalog = AppCatalog()
    let settings = LaunchpadSettings()
    private var shortcuts: ShortcutManager?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        catalog.refresh()
        WallpaperStore.shared.preloadMainScreen()
        let urls = catalog.apps.compactMap(\.url)
        Task.detached(priority: .background) {
            await IconStore.shared.prewarm(urls: urls)
        }
        controller.attachCatalog(catalog)
        controller.attachSettings(settings)
        shortcuts = ShortcutManager(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers) { [weak self] in
            self?.controller.toggle()
        }
        settings.hotkeyConflict = !(shortcuts?.isRegistered ?? true)
        settings.$hotkeyKeyCode
            .combineLatest(settings.$hotkeyModifiers)
            .dropFirst()
            .sink { [weak self] keyCode, modifiers in
                guard let self else { return }
                self.settings.hotkeyConflict = !(self.shortcuts?.register(keyCode: keyCode, modifiers: modifiers) ?? true)
            }
            .store(in: &cancellables)
    }

    /// 快捷键录制期间暂停全局热键，避免录制 F 键时触发 LaunchPad。
    func setHotkeyPaused(_ paused: Bool) {
        if paused {
            shortcuts?.unregister()
        } else {
            settings.hotkeyConflict = !(shortcuts?.register(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers) ?? true)
        }
    }
}
