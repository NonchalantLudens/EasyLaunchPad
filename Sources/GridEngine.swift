import Foundation
import CoreGraphics

struct GridLayout: Equatable {
    let columns: Int
    let rows: Int

    var perPage: Int { columns * rows }

    static func layout(for size: CGSize, itemWidth: CGFloat = 176, itemHeight: CGFloat = 186) -> GridLayout {
        let cols = max(1, Int(floor(size.width / itemWidth)))
        let rows = max(1, Int(floor(size.height / itemHeight)))
        return GridLayout(columns: cols, rows: rows)
    }

    func pages<T>(_ items: [T]) -> [[T]] {
        guard perPage > 0, !items.isEmpty else { return [] }
        var result: [[T]] = []
        var start = 0
        while start < items.count {
            result.append(Array(items[start..<min(start + perPage, items.count)]))
            start += perPage
        }
        return result
    }

    func pageCounts<T>(_ items: [T]) -> [Int] {
        pages(items).map(\.count)
    }
}

enum GridDirection {
    case left, right, up, down
}

struct GridSelection: Equatable {
    var pageIndex: Int
    var itemIndex: Int

    static let zero = GridSelection(pageIndex: 0, itemIndex: 0)
}

enum GridNavigation {
    static func move(
        _ direction: GridDirection,
        from selection: GridSelection,
        pageCounts: [Int],
        columns: Int
    ) -> GridSelection {
        guard !pageCounts.isEmpty, columns > 0 else { return .zero }
        var s = selection
        let pageCount = pageCounts[s.pageIndex]
        switch direction {
        case .left:
            if s.itemIndex > 0 {
                s.itemIndex -= 1
            } else if s.pageIndex > 0 {
                s.pageIndex -= 1
                s.itemIndex = max(0, pageCounts[s.pageIndex] - 1)
            }
        case .right:
            if s.itemIndex + 1 < pageCount {
                s.itemIndex += 1
            } else if s.pageIndex + 1 < pageCounts.count {
                s.pageIndex += 1
                s.itemIndex = 0
            }
        case .up:
            if s.itemIndex >= columns {
                s.itemIndex -= columns
            } else if s.pageIndex > 0 {
                let prevCount = pageCounts[s.pageIndex - 1]
                s.pageIndex -= 1
                s.itemIndex = min(max(0, prevCount - columns + s.itemIndex), prevCount - 1)
            }
        case .down:
            if s.itemIndex + columns < pageCount {
                s.itemIndex += columns
            } else if s.pageIndex + 1 < pageCounts.count {
                let nextCount = pageCounts[s.pageIndex + 1]
                s.pageIndex += 1
                s.itemIndex = min(s.itemIndex % columns, max(0, nextCount - 1))
            }
        }
        return s
    }

    static func clamp(_ selection: GridSelection, pageCounts: [Int]) -> GridSelection {
        guard !pageCounts.isEmpty else { return .zero }
        let page = min(max(0, selection.pageIndex), pageCounts.count - 1)
        let item = min(max(0, selection.itemIndex), max(0, pageCounts[page] - 1))
        return GridSelection(pageIndex: page, itemIndex: item)
    }

    static func page(_ index: Int, pageCounts: [Int]) -> GridSelection {
        guard !pageCounts.isEmpty else { return .zero }
        return GridSelection(pageIndex: min(max(0, index), pageCounts.count - 1), itemIndex: 0)
    }
}
