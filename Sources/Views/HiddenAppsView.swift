import AppKit
import SwiftUI

struct HiddenAppsView: View {
    @EnvironmentObject private var catalog: AppCatalog

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("隐藏的应用")
                .font(.headline)
                .padding(.bottom, 10)
            if catalog.hiddenRecords.isEmpty {
                Spacer()
                Text("没有隐藏的应用")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(catalog.hiddenRecords, id: \.id) { record in
                    HStack(spacing: 10) {
                        Image(nsImage: record.url.map { NSWorkspace.shared.icon(forFile: $0.path) }
                            ?? NSWorkspace.shared.icon(for: .application))
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(record.name)
                        Spacer()
                        Button("恢复") {
                            catalog.unhide(record.id)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 380, height: 300)
    }
}
