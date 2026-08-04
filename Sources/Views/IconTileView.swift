import AppKit
import SwiftUI

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let highlight: String
    let jiggle: Double
    let deleteMode: Bool
    let size: IconSizeLevel
    let entered: Bool
    let revealDelay: Double
    let animationEnabled: Bool
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
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: size.iconCornerRadius, style: .continuous)
                            .fill(.white.opacity(isSelected ? 0.25 : 0))
                            .frame(width: size.ringPoint, height: size.ringPoint)
                            .scaleEffect(isSelected ? 1 : 0.9)
                            .animation(.spring(duration: 0.25), value: isSelected)
                        iconView
                    }
                    Text(attributedName)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                        .frame(width: size.nameWidth, height: 34)
                }
                .frame(width: size.tileWidth, height: size.tileHeight)
                .contentShape(Rectangle())
                .compositingGroup()
            }
            .buttonStyle(.plain)
            .overlay(alignment: .topTrailing) {
                if deleteMode {
                    Button(action: onBadge) {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white, .red)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, size.badgeTrailing)
                    .padding(.top, size.badgeTop)
                }
            }
        }
        .rotationEffect(.degrees(jiggle))
        .offset(x: jiggle * 0.55)
        .opacity(entered ? 1 : 0)
        .offset(y: entered ? 0 : 40)
        .scaleEffect(entered ? 1 : 0.85)
        .animation(
            animationEnabled
                ? .spring(response: 0.28, dampingFraction: 0.8).delay(revealDelay)
                : nil,
            value: entered
        )
        .transition(.scale(scale: 0.6).combined(with: .opacity))
        .task(id: app.id) {
            icon = await IconStore.shared.icon(for: app.url)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: size.iconPoint, height: size.iconPoint)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        } else {
            RoundedRectangle(cornerRadius: size.iconCornerRadius - 4, style: .continuous)
                .fill(.white.opacity(0.12))
                .frame(width: size.iconPoint, height: size.iconPoint)
        }
    }
}
