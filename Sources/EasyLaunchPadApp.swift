import SwiftUI

@main
struct EasyLaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let state = AppState.shared

    var body: some Scene {
        MenuBarExtra("EasyLaunchPad", systemImage: "square.grid.3x3") {
            MenuBarMenuView()
                .environmentObject(state)
                .environmentObject(state.updateManager)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(state)
                .environmentObject(state.settings)
                .environmentObject(state.catalog)
                .environmentObject(state.updateManager)
        }
    }
}
