import AppKit
import SwiftUI

/// 隐藏应用列表（菜单栏 sheet 与设置页「应用管理」共用）。
struct HiddenAppsList: View {
    @EnvironmentObject private var catalog: AppCatalog

    var body: some View {
        if catalog.hiddenRecords.isEmpty {
            Text("没有隐藏的应用")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
        } else {
            List(catalog.hiddenRecords, id: \.id) { record in
                HStack(spacing: 10) {
                    Image(nsImage: record.url.map { NSWorkspace.shared.icon(forFile: $0.path) }
                        ?? NSWorkspace.shared.icon(for: .application))
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text(record.name)
                    Spacer()
                    Button("恢复") {
                        catalog.unhide(record.id)
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
