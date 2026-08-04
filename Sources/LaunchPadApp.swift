import SwiftUI

@main
struct LaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let state = AppState.shared

    var body: some Scene {
        MenuBarExtra("LaunchPad", systemImage: "square.grid.3x3") {
            MenuBarMenuView()
                .environmentObject(state)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(state)
                .environmentObject(state.settings)
                .environmentObject(state.catalog)
        }
    }
}
