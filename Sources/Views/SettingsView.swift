import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: LaunchpadSettings
    @EnvironmentObject private var catalog: AppCatalog

    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(settings)
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }
            GestureSettingsView()
                .environmentObject(settings)
                .tabItem {
                    Label("手势", systemImage: "hand.point.up.left")
                }
            AppManageSettingsView()
                .environmentObject(catalog)
                .tabItem {
                    Label("应用管理", systemImage: "square.grid.3x3")
                }
            AboutSettingsView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 480, height: 400)
    }
}
