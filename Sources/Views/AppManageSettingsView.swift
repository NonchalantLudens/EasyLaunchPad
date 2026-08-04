import SwiftUI
import UniformTypeIdentifiers

struct AppManageSettingsView: View {
    @EnvironmentObject private var catalog: AppCatalog

    var body: some View {
        Form {
            Section {
                Button {
                    addApp()
                } label: {
                    Label("添加应用…", systemImage: "plus.circle")
                }
            }
            Section("隐藏的应用") {
                HiddenAppsList()
            }
        }
        .formStyle(.grouped)
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
                catalog.addManual(url)
            }
        }
    }
}
