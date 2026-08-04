import AppKit
import SwiftUI

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let action: () -> Void

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
                Text(app.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                    .frame(width: 100, height: 30)
            }
            .frame(width: 100, height: 110)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
