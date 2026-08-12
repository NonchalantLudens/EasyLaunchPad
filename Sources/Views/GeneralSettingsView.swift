import AppKit
import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: EasyLaunchPadSettings
    @EnvironmentObject private var updateManager: UpdateManager
    @State private var statusText = ""

    var body: some View {
        Form {
            Section("快捷键") {
                HStack {
                    Text("呼出 / 关闭 EasyLaunchPad")
                    Spacer()
                    HotkeyRecorderView { paused in
                        state.setHotkeyPaused(paused)
                    }
                    .environmentObject(settings)
                }
                if settings.hotkeyConflict {
                    Label("快捷键已被其他应用占用，请更换", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("点击后按下新快捷键（需包含 ⌘⌥⌃⇧ 或功能键），按 Esc 取消")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section("显示") {
                HStack {
                    Text("图标大小")
                    Spacer()
                    Picker("图标大小", selection: $settings.iconSize) {
                        ForEach(IconSizeLevel.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 220)
                }
                Toggle("图标入场动画", isOn: $settings.iconEntryAnimation)
                Toggle("显示系统应用", isOn: $settings.showSystemApps)
                Text("关闭后不扫描 /System/Applications；系统应用（如计算器）可按住 Option 按需隐藏。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("软件更新") {
                Toggle("自动检查更新", isOn: $settings.autoCheckUpdates)
                HStack {
                    Text("当前版本 \(updateManager.currentVersion)")
                    Spacer()
                    Button(updateManager.state == .checking ? "检查中…" : "检查更新") {
                        updateManager.checkForUpdates()
                    }
                    .disabled(updateManager.state == .checking)
                }
                updateStatusView
            }
            Section("启动") {
                Toggle("登录时自动启动", isOn: $settings.autoStart)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let error = settings.autoStartError {
                    HStack {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Spacer()
                        Button("在访达中显示") {
                            NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            statusText = settings.autoStartStatusText()
        }
        .onChange(of: settings.autoStart) { _, _ in
            statusText = settings.autoStartStatusText()
        }
    }

    @ViewBuilder
    private var updateStatusView: some View {
        switch updateManager.state {
        case .idle:
            EmptyView()
        case .checking:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在检查更新…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .upToDate:
            Text("已是最新版本")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .updateAvailable(let release):
            VStack(alignment: .leading, spacing: 6) {
                Label("发现新版本 v\(release.version)", systemImage: "arrow.down.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Button("下载并安装 v\(release.version)") {
                    updateManager.downloadAndInstall(release)
                }
                .controlSize(.small)
            }
        case .downloading:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在下载更新…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .installing:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("正在安装，完成后将自动重启…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.red)
        }
    }
}
