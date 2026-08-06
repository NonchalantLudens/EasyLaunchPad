import AppKit
import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: EasyLaunchPadSettings
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
}
