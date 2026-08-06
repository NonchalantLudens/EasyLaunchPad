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
            Button {
                if let url = URL(string: "https://github.com/NonchalantLudens/EasyLaunchPad") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("GitHub 仓库")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .underline()
            }
            .buttonStyle(.plain)
            Text("© 2026 NonchalantLudens")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
