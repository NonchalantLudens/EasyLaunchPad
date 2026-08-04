import AppKit
import SwiftUI

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let highlight: String
    let revealDelay: Double
    let action: () -> Void

    @State private var revealed = false

    private var attributedName: AttributedString {
        var result = AttributedString(app.name)
        result.font = .system(size: 12, weight: .medium)
        result.foregroundColor = .white
        if !highlight.isEmpty, let range = result.range(of: highlight, options: [.caseInsensitive]) {
            result[range].font = .system(size: 12, weight: .bold)
            result[range].backgroundColor = .white.opacity(0.25)
        }
        return result
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(.white.opacity(isSelected ? 0.25 : 0))
                        .frame(width: 76, height: 76)
                        .scaleEffect(isSelected ? 1 : 0.9)
                        .animation(.spring(duration: 0.25), value: isSelected)
                    Image(nsImage: app.icon)
                        .resizable()
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                }
                Text(attributedName)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                    .frame(width: 100, height: 30)
            }
            .frame(width: 100, height: 110)
            .contentShape(Rectangle())
            .opacity(revealed ? 1 : 0)
            .scaleEffect(revealed ? 1 : 0.9)
            .animation(.easeOut(duration: 0.3).delay(revealDelay), value: revealed)
        }
        .buttonStyle(.plain)
        .onAppear {
            revealed = true
        }
        .onChange(of: app) { _, _ in
            revealed = true
        }
    }
}
