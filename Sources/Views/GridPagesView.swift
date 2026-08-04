import SwiftUI

struct GridPagesView: View {
    let pages: [[AppItem]]
    let selection: GridSelection
    let columns: Int
    let highlight: String
    let deleteMode: Bool
    let jigglePhase: Double
    let onSelect: (AppItem) -> Void
    let onBadge: (AppItem) -> Void

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    GridPageView(
                        page: page,
                        columns: columns,
                        highlight: highlight,
                        pageIndex: index,
                        deleteMode: deleteMode,
                        jigglePhase: jigglePhase,
                        selectedIndex: selection.pageIndex == index ? selection.itemIndex : nil,
                        onSelect: onSelect,
                        onBadge: onBadge
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
    let highlight: String
    let pageIndex: Int
    let deleteMode: Bool
    let jigglePhase: Double
    let selectedIndex: Int?
    let onSelect: (AppItem) -> Void
    let onBadge: (AppItem) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(140), spacing: 32), count: columns),
            spacing: 36
        ) {
            ForEach(Array(page.enumerated()), id: \.offset) { index, app in
                IconTileView(
                    app: app,
                    isSelected: selectedIndex == index,
                    highlight: highlight,
                    jiggle: deleteMode
                        ? sin(jigglePhase + Double(index) * 0.7) * 1.2
                        : 0,
                    deleteMode: deleteMode,
                    action: { onSelect(app) },
                    onBadge: { onBadge(app) }
                )
            }
        }
    }
}
