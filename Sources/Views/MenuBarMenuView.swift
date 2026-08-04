import SwiftUI
import UniformTypeIdentifiers

struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState
    @State private var showHiddenApps = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(state.controller.isVisible ? "关闭 LaunchPad" : "打开 LaunchPad") {
                state.controller.toggle()
            }
            Divider()
            Button("添加应用…") {
                addApp()
            }
            Button("隐藏的应用…") {
                showHiddenApps = true
            }
            Divider()
            Button("偏好设置…") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            Divider()
            Button("退出 LaunchPad") {
                NSApp.terminate(nil)
            }
        }
        .padding(4)
        .sheet(isPresented: $showHiddenApps) {
            HiddenAppsView()
                .environmentObject(state.catalog)
        }
    }

    private func addApp() {
        let panel = NSOpenPanel()
        panel.title = "添加应用到 LaunchPad"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.begin { response in
            guard response == .OK else { return }
            for url in panel.urls {
                state.catalog.addManual(url)
            }
        }
    }
}
