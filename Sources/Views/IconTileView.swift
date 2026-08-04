import AppKit
import SwiftUI

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let highlight: String
    let jiggle: Double
    let deleteMode: Bool
    let action: () -> Void
    let onBadge: () -> Void

    @State private var icon: NSImage?

    private var attributedName: AttributedString {
        var result = AttributedString(app.name)
        result.font = .system(size: 13, weight: .medium)
        result.foregroundColor = .white
        if !highlight.isEmpty, let range = result.range(of: highlight, options: [.caseInsensitive]) {
            result[range].font = .system(size: 13, weight: .bold)
            result[range].backgroundColor = .white.opacity(0.25)
        }
        return result
    }

    var body: some View {
        ZStack {
            Button(action: deleteMode ? {} : action) {
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white.opacity(isSelected ? 0.25 : 0))
                            .frame(width: 100, height: 100)
                            .scaleEffect(isSelected ? 1 : 0.9)
                            .animation(.spring(duration: 0.25), value: isSelected)
                        iconView
                        if deleteMode {
                            Button(action: onBadge) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white, .red)
                            }
                            .buttonStyle(.plain)
                            .offset(x: 40, y: -40)
                        }
                    }
                    Text(attributedName)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                        .frame(width: 132, height: 34)
                }
                .frame(width: 140, height: 150)
                .contentShape(Rectangle())
                .compositingGroup()
            }
            .buttonStyle(.plain)
        }
        .rotationEffect(.degrees(jiggle))
        .offset(x: jiggle * 0.55)
        .task(id: app.id) {
            icon = await IconStore.shared.icon(for: app.url)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 96, height: 96)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.12))
                .frame(width: 96, height: 96)
        }
    }
}
