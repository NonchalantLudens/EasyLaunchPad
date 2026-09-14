import SwiftUI

@main
struct EasyLaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let state = AppState.shared

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(state)
                .environmentObject(state.settings)
                .environmentObject(state.catalog)
                .environmentObject(state.updateManager)
        }
    }
}
