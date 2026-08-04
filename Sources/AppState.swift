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
        settings.$hotkeyKeyCode
            .combineLatest(settings.$hotkeyModifiers)
            .dropFirst()
            .sink { [weak self] keyCode, modifiers in
                self?.shortcuts?.register(keyCode: keyCode, modifiers: modifiers)
            }
            .store(in: &cancellables)
    }
}
