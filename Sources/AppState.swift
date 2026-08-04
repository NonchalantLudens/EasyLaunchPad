import AppKit
import Carbon.HIToolbox

@MainActor
final class AppState: ObservableObject {
    let controller = LaunchPadController()
    let catalog = AppCatalog()
    private var shortcuts: ShortcutManager?

    init() {
        catalog.refresh()
        shortcuts = ShortcutManager(keyCode: UInt32(kVK_F4), modifiers: 0) { [weak self] in
            self?.controller.toggle()
        }
    }
}
