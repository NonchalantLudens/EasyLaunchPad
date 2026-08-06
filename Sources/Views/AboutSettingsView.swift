import AppKit
import SwiftUI

struct AboutSettingsView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
            Text("EasyLaunchPad")
                .font(.title2.weight(.semibold))
            Text("版本 \(version) (\(build))")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("还原经典 Launchpad 的全屏应用启动器：网格分页、实时搜索、删除模式、触控板手势与全局快捷键。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            Text("SwiftUI · macOS 15+")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("© 2026")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
