import AppKit
import Carbon.HIToolbox
import Combine

@MainActor
final class AppState: ObservableObject {
    /// 全局单例：菜单栏、设置、热键与 Dock 图标入口共享同一实例，
    /// 避免多个 AppState 各自持有设置快照导致改动不生效。
    static let shared = AppState()

    let controller = LaunchPadController()
    let catalog = AppCatalog()
    let settings = LaunchpadSettings()
    private var shortcuts: ShortcutManager?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        catalog.refresh()
        WallpaperStore.shared.preloadMainScreen()
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
        // 后台扫描完成后（首次发布非空列表）再预热图标
        catalog.$apps
            .filter { !$0.isEmpty }
            .first()
            .sink { apps in
                let urls = apps.compactMap(\.url)
                Task.detached(priority: .background) {
                    await IconStore.shared.prewarm(urls: urls)
                }
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
