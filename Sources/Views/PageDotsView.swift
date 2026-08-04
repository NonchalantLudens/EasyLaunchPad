import SwiftUI

struct PageDotsView: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(index == currentPage ? 1 : 0.45))
                    .frame(
                        width: index == currentPage ? 14 : 10,
                        height: index == currentPage ? 14 : 10
                    )
                    .shadow(color: .black.opacity(0.5), radius: 1.5, y: 1)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.vertical, 20)
    }
}
