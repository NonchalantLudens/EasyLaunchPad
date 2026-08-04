import SwiftUI
import UniformTypeIdentifiers

struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Button(state.controller.isVisible ? "关闭 LaunchPad" : "打开 LaunchPad") {
            state.controller.toggle()
        }
        Divider()
        Button("添加应用…") {
            addApp()
        }
        Menu("隐藏的应用") {
            if state.catalog.hiddenRecords.isEmpty {
                Text("无隐藏应用")
            } else {
                ForEach(state.catalog.hiddenRecords, id: \.id) { record in
                    Button("恢复「\(record.name)」") {
                        state.catalog.unhide(record.id)
                    }
                }
            }
        }
        Divider()
        SettingsLink {
            Text("偏好设置…")
        }
        Button("关于 LaunchPad…") {
            NSApp.orderFrontStandardAboutPanel(nil)
        }
        Divider()
        Button("退出 LaunchPad") {
            NSApp.terminate(nil)
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
