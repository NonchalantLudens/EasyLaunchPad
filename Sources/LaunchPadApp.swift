import SwiftUI

@main
struct LaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra("LaunchPad", systemImage: "square.grid.3x3") {
            MenuBarMenuView()
                .environmentObject(state)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(state)
                .environmentObject(state.settings)
                .environmentObject(state.catalog)
        }
    }
}
