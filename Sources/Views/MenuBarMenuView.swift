import SwiftUI

/// 菜单栏面板中的行按钮：悬停高亮（模拟原生菜单项）。
struct MenuPanelButton: View {
    let title: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Text(title)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
            .onTapGesture(perform: action)
    }
}

/// 菜单栏图标下拉面板：仅保留入口动作，更新流程在独立窗口中进行。
struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var updateManager: UpdateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            MenuPanelButton(title: state.controller.isVisible ? "关闭 EasyLaunchPad" : "打开 EasyLaunchPad") {
                state.controller.toggle()
            }

            Divider()

            MenuPanelButton(title: "检查更新…") {
                updateManager.checkForUpdates()
                UpdatePanelPresenter.present(updateManager)
            }
            SettingsLink {
                Text("偏好设置…")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .contentShape(Rectangle())
            }
            MenuPanelButton(title: "关于 EasyLaunchPad…") {
                NSApp.orderFrontStandardAboutPanel(nil)
            }

            Divider()

            MenuPanelButton(title: "退出 EasyLaunchPad") {
                NSApp.terminate(nil)
            }
        }
        .padding(8)
        .frame(width: 240)
    }
}
