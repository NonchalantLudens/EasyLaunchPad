import SwiftUI

struct PageDotsView: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(index == currentPage ? 1 : 0.4))
                    .frame(width: index == currentPage ? 11 : 9, height: index == currentPage ? 11 : 9)
                    .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.vertical, 20)
    }
}
