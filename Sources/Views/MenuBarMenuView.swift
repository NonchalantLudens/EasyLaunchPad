import AppKit
import SwiftUI

/// 菜单栏面板中的行按钮：悬停高亮（模拟原生菜单项）。
/// 面板所有条目统一使用本组件，保证样式一致。
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

/// 菜单栏图标下拉面板。
/// 交互约定：
/// - 普通条目点击后先收起面板再执行动作
/// - 「检查更新」例外：保留面板，原地展示检查 / 结果 / 下载 / 安装状态
struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var controller: EasyLaunchPadController
    @EnvironmentObject private var updateManager: UpdateManager
    @EnvironmentObject private var statusBar: StatusBarPanelController

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            MenuPanelButton(title: controller.isVisible ? "关闭 EasyLaunchPad" : "打开 EasyLaunchPad") {
                statusBar.hide()
                state.controller.toggle()
            }

            Divider()

            MenuPanelButton(title: "检查更新…") {
                updateManager.checkForUpdates()
            }
            if updateManager.state != .idle {
                MenuUpdateStatusView()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
            }
            MenuPanelButton(title: "偏好设置…") {
                statusBar.hide()
                openSettings()
            }
            MenuPanelButton(title: "关于 EasyLaunchPad…") {
                statusBar.hide()
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel(nil)
            }

            Divider()

            MenuPanelButton(title: "退出 EasyLaunchPad") {
                statusBar.hide()
                NSApp.terminate(nil)
            }
        }
        .padding(8)
        .frame(width: 244)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    /// 打开设置窗口：先激活应用再走 showSettingsWindow 动作。
    /// 不用 SettingsLink——面板处于非激活状态时它经常无响应。
    private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

/// 面板内联的更新状态：检查中 / 最新 / 新版本 / 下载进度 / 安装 / 失败重试。
struct MenuUpdateStatusView: View {
    @EnvironmentObject private var updateManager: UpdateManager

    var body: some View {
        switch updateManager.state {
        case .idle:
            EmptyView()

        case .checking:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在检查更新…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

        case .upToDate:
            Label("已是最新版本", systemImage: "checkmark.circle.fill")
                .font(.callout)
                .foregroundStyle(.green)

        case .updateAvailable(let release):
            VStack(alignment: .leading, spacing: 6) {
                Label("发现新版本 v\(release.version)", systemImage: "arrow.down.circle")
                    .font(.callout)
                    .foregroundStyle(.orange)
                Button("下载并安装 v\(release.version)") {
                    updateManager.downloadAndInstall(release)
                }
                .controlSize(.small)
            }

        case .downloading(let release):
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("正在下载 v\(release.version)")
                        .font(.callout)
                    Spacer()
                    Text("\(Int((updateManager.downloadProgress * 100).rounded()))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: updateManager.downloadProgress)
            }

        case .installing:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在安装，完成后将自动重启…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 6) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .lineLimit(3)
                Button("重试") {
                    updateManager.checkForUpdates()
                }
                .controlSize(.small)
            }
        }
    }
}
