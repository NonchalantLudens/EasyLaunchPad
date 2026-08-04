import SwiftUI

struct PageDotsView: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(index == currentPage ? 0.9 : 0.35))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.15 : 1)
            }
        }
        .padding(.vertical, 20)
    }
}
