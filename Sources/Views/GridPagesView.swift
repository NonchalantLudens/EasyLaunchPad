import SwiftUI

struct GridPagesView: View {
    let pages: [[AppItem]]
    let selection: GridSelection
    let columns: Int
    let onSelect: (AppItem) -> Void

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    GridPageView(
                        page: page,
                        columns: columns,
                        selectedIndex: selection.pageIndex == index ? selection.itemIndex : nil,
                        onSelect: onSelect
                    )
                    .frame(width: geo.size.width)
                }
            }
            .offset(x: -CGFloat(selection.pageIndex) * geo.size.width)
            .animation(.easeInOut(duration: 0.3), value: selection.pageIndex)
        }
    }
}

struct GridPageView: View {
    let page: [AppItem]
    let columns: Int
    let selectedIndex: Int?
    let onSelect: (AppItem) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(110), spacing: 24), count: columns),
            spacing: 28
        ) {
            ForEach(Array(page.enumerated()), id: \.offset) { index, app in
                IconTileView(app: app, isSelected: selectedIndex == index) {
                    onSelect(app)
                }
            }
        }
    }
}
