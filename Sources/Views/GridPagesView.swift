import SwiftUI

struct GridPagesView: View {
    let pages: [[AppItem]]
    let selection: GridSelection
    let columns: Int
    let highlight: String
    let deleteMode: Bool
    let jigglePhase: Double
    let size: IconSizeLevel
    let entered: Bool
    let animationEnabled: Bool
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
                        size: size,
                        entered: entered,
                        animationEnabled: animationEnabled,
                        selectedIndex: selection.pageIndex == index ? selection.itemIndex : nil,
                        onSelect: onSelect,
                        onBadge: onBadge
                    )
                    // 所有页面同宽同高、内容顶部对齐，保证页间布局一致
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                }
            }
            .offset(x: -CGFloat(selection.pageIndex) * geo.size.width)
            .animation(.easeInOut(duration: 0.18), value: selection.pageIndex)
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
    let size: IconSizeLevel
    let entered: Bool
    let animationEnabled: Bool
    let selectedIndex: Int?
    let onSelect: (AppItem) -> Void
    let onBadge: (AppItem) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(size.tileWidth), spacing: size.spacing), count: columns),
            spacing: size.spacing
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
                    size: size,
                    entered: entered,
                    revealDelay: Double(index / columns) * 0.04,
                    animationEnabled: animationEnabled,
                    action: { onSelect(app) },
                    onBadge: { onBadge(app) }
                )
            }
        }
    }
}
