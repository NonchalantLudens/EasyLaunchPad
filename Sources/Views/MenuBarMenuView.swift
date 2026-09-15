import AppKit
import SwiftUI

/// 菜单栏图标下拉面板。
/// 交互约定：
/// - 普通条目点击后先收起面板再执行动作
/// - 「检查更新」例外：保留面板，状态在行内展示；
///   信息性结果（已是最新 / 失败）短暂显示后自动复原，不常驻
struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var controller: EasyLaunchPadController
    @EnvironmentObject private var updateManager: UpdateManager
    @EnvironmentObject private var statusBar: StatusBarPanelController

    /// 信息性状态展示时长，之后自动复原为空闲。
    private let transientStatusLifetime: UInt64 = 4_000_000_000

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            MenuPanelButton(title: controller.isVisible ? "关闭 EasyLaunchPad" : "打开 EasyLaunchPad") {
                statusBar.hide()
                state.controller.toggle()
            }

            Divider()

            checkUpdateRow

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

    /// 打开设置窗口：AppKit 自持窗口，不依赖应用激活状态。
    private func openSettings() {
        SettingsWindowController.shared.show(state: state)
    }

    // MARK: - 检查更新（行内状态）

    @ViewBuilder
    private var checkUpdateRow: some View {
        switch updateManager.state {
        case .idle:
            MenuPanelButton(title: "检查更新…") {
                updateManager.checkForUpdates()
            }

        case .checking:
            MenuPanelButton(title: "检查更新…", action: {}, trailing: {
                ProgressView()
                    .controlSize(.small)
            })

        case .upToDate:
            MenuPanelButton(title: "检查更新…", action: {}, trailing: {
                Text("已是最新")
                    .font(.caption)
                    .foregroundStyle(.green)
            })
            .task(id: updateManager.state) {
                try? await Task.sleep(nanoseconds: transientStatusLifetime)
                updateManager.clearTransientStatus()
            }

        case .failed:
            MenuPanelButton(title: "检查更新…", action: {}, trailing: {
                Text("失败，点击重试")
                    .font(.caption)
                    .foregroundStyle(.red)
            })
            .task(id: updateManager.state) {
                try? await Task.sleep(nanoseconds: transientStatusLifetime)
                updateManager.clearTransientStatus()
            }

        case .updateAvailable(let release):
            MenuPanelButton(
                title: "下载并安装 v\(release.version)",
                titleColor: .orange,
                action: { updateManager.downloadAndInstall(release) }
            )

        case .downloading(let release):
            MenuPanelButton(
                title: "下载中 v\(release.version)",
                action: {},
                trailing: {
                    Text("\(Int((updateManager.downloadProgress * 100).rounded()))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            )

        case .installing:
            MenuPanelButton(title: "正在安装，将自动重启", action: {}, trailing: {
                ProgressView()
                    .controlSize(.small)
            })
        }
    }
}
