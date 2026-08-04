import AppKit
import SwiftUI

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let highlight: String
    let revealDelay: Double
    let deleteMode: Bool
    let action: () -> Void
    let onBadge: () -> Void

    @State private var revealed = false

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
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 96, height: 96)
                            .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                        if deleteMode {
                            Button(action: onBadge) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(.white, .red)
                            }
                            .buttonStyle(.plain)
                            .offset(x: 48, y: -48)
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
                .opacity(revealed ? 1 : 0)
                .scaleEffect(revealed ? 1 : 0.92)
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.8).delay(revealDelay),
                    value: revealed
                )
            }
            .buttonStyle(.plain)
        }
        .jiggle(deleteMode)
        .onAppear {
            revealed = true
        }
        .onChange(of: app) { _, _ in
            revealed = true
        }
    }
}
