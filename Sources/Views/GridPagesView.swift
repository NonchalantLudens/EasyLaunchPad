import SwiftUI

/// 首个图块的原点信息：页面坐标空间（命中测试用）与根坐标空间（悬浮图标定位用）。
struct GridOriginInfo: Equatable {
    var page: CGPoint = .zero
    var root: CGPoint = .zero
}

struct GridOriginInfoKey: PreferenceKey {
    static var defaultValue = GridOriginInfo()
    static func reduce(value: inout GridOriginInfo, nextValue: () -> GridOriginInfo) {
        value = nextValue()
    }
}

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
    // 拖拽排序
    let dragEnabled: Bool
    let dragAppID: String?
    let onGridOrigin: (GridOriginInfo) -> Void
    let onDragStart: (AppItem, CGPoint) -> Void
    let onDragMove: (AppItem, CGPoint) -> Void
    let onDragEnd: (AppItem, CGPoint) -> Void
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
                        spaceName: "gridPage-\(index)",
                        dragEnabled: dragEnabled,
                        dragAppID: dragAppID,
                        onDragStart: onDragStart,
                        onDragMove: onDragMove,
                        onDragEnd: onDragEnd,
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
        .onPreferenceChange(GridOriginInfoKey.self) { onGridOrigin($0) }
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
    let spaceName: String
    let dragEnabled: Bool
    let dragAppID: String?
    let onDragStart: (AppItem, CGPoint) -> Void
    let onDragMove: (AppItem, CGPoint) -> Void
    let onDragEnd: (AppItem, CGPoint) -> Void
    let selectedIndex: Int?
    let onSelect: (AppItem) -> Void
    let onBadge: (AppItem) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(size.tileWidth), spacing: size.spacing), count: columns),
            spacing: size.spacing
        ) {
            ForEach(Array(page.enumerated()), id: \.element.id) { index, app in
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
                    revealDelay: Double(index / columns) * 0.025,
                    animationEnabled: animationEnabled,
                    action: { onSelect(app) },
                    onBadge: { onBadge(app) },
                    dragSpaceName: dragEnabled ? spaceName : nil,
                    isDragged: dragAppID == app.id,
                    reportsGridOrigin: index == 0,
                    onDragStarted: dragEnabled ? { onDragStart(app, $0) } : nil,
                    onDragMoved: dragEnabled ? { onDragMove(app, $0) } : nil,
                    onDragEnded: dragEnabled ? { onDragEnd(app, $0) } : nil
                )
            }
        }
        .coordinateSpace(name: spaceName)
    }
}
