import AppKit
import SwiftUI

/// 独立更新界面窗口：展示检查/结果/下载进度/安装的完整状态流转。
enum UpdatePanelPresenter {
    private static var window: NSWindow?

    @MainActor
    static func present(_ updateManager: UpdateManager) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let panel = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "软件更新"
        panel.contentView = NSHostingView(rootView: UpdateStatusView()
            .environmentObject(updateManager))
        panel.isReleasedWhenClosed = false
        panel.center()
        panel.level = .floating
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = panel
    }
}

/// 更新状态视图：检查中 / 最新 / 新版本安装 / 下载进度条 / 安装中 / 失败重试。
struct UpdateStatusView: View {
    @EnvironmentObject private var updateManager: UpdateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("EasyLaunchPad")
                        .font(.headline)
                    Text("当前版本 v\(updateManager.currentVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            statusBody

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(width: 320, height: 160, alignment: .top)
    }

    @ViewBuilder
    private var statusBody: some View {
        switch updateManager.state {
        case .idle:
            Text("点击「检查更新」获取最新版本。")
                .font(.callout)
                .foregroundStyle(.secondary)

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
            VStack(alignment: .leading, spacing: 10) {
                Label("发现新版本 v\(release.version)", systemImage: "arrow.down.circle")
                    .font(.callout)
                    .foregroundStyle(.orange)
                Button("下载并安装 v\(release.version)") {
                    updateManager.downloadAndInstall(release)
                }
                .controlSize(.regular)
            }

        case .downloading(let release):
            VStack(alignment: .leading, spacing: 6) {
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

        case .installing(let release):
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在安装 v\(release.version)，完成后自动重启…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 10) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                Button("重试") {
                    updateManager.checkForUpdates()
                }
                .controlSize(.regular)
            }
        }
    }
}
