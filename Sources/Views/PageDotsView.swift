import SwiftUI

struct PageDotsView: View {
    let pageCount: Int
    let currentPage: Int
    var onSelect: ((Int) -> Void)? = nil

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
                    .frame(width: 22, height: 22) // 扩大点击热区
                    .contentShape(Rectangle())
                    .onTapGesture { onSelect?(index) }
            }
        }
        .padding(.vertical, 20)
    }
}
