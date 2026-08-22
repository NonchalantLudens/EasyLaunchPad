import SwiftUI

/// 菜单栏图标的下拉面板：内联展示更新状态（检查中 / 最新 / 新版本 / 下载进度 / 失败重试）。
struct MenuBarMenuView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var updateManager: UpdateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(state.controller.isVisible ? "关闭 EasyLaunchPad" : "打开 EasyLaunchPad") {
                state.controller.toggle()
            }
            .buttonStyle(.plain)

            Divider()

            updateSection

            Divider()

            SettingsLink {
                Text("偏好设置…")
            }
            .buttonStyle(.plain)
            Button("关于 EasyLaunchPad…") {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
            .buttonStyle(.plain)

            Divider()

            Button("退出 EasyLaunchPad") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 260)
    }

    @ViewBuilder
    private var updateSection: some View {
        switch updateManager.state {
        case .idle:
            Button("检查更新…") {
                updateManager.checkForUpdates()
            }
            .buttonStyle(.plain)

        case .checking:
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                Text("正在检查更新…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

        case .upToDate:
            Label("已是最新版本 v\(updateManager.currentVersion)", systemImage: "checkmark.circle.fill")
                .font(.callout)
                .foregroundStyle(.secondary)

        case .updateAvailable(let release):
            VStack(alignment: .leading, spacing: 6) {
                Label("发现新版本 v\(release.version)", systemImage: "arrow.down.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                Button("下载并安装 v\(release.version)") {
                    updateManager.downloadAndInstall(release)
                }
                .buttonStyle(.plain)
            }

        case .downloading(let release):
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("正在下载 v\(release.version)")
                        .font(.caption)
                    Spacer()
                    Text("\(Int((updateManager.downloadProgress * 100).rounded()))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: updateManager.downloadProgress)
            }

        case .installing(let release):
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                Text("正在安装 v\(release.version)，完成后自动重启…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 4) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Button("重试检查更新") {
                    updateManager.checkForUpdates()
                }
                .controlSize(.small)
                .buttonStyle(.plain)
            }
        }
    }
}
