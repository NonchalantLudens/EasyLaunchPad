import XCTest
@testable import LaunchPad

final class GridLayoutTests: XCTestCase {
    func testLayoutColumnsAndRows() {
        let layout = GridLayout.layout(for: CGSize(width: 1400, height: 900))
        XCTAssertEqual(layout.columns, 10)
        XCTAssertEqual(layout.rows, 6)
        XCTAssertEqual(layout.perPage, 60)
    }

    func testLayoutMinimumOne() {
        let layout = GridLayout.layout(for: CGSize(width: 50, height: 50))
        XCTAssertEqual(layout.columns, 1)
        XCTAssertEqual(layout.rows, 1)
    }

    func testPagesEmpty() {
        let layout = GridLayout(columns: 4, rows: 3)
        XCTAssertEqual(layout.pages([Int]()).count, 0)
    }

    func testPagesExactMultiple() {
        let layout = GridLayout(columns: 2, rows: 2)
        XCTAssertEqual(layout.pages(Array(0..<8)).map(\.count), [4, 4])
    }

    func testPagesPartialLastPage() {
        let layout = GridLayout(columns: 2, rows: 2)
        let pages = layout.pages(Array(0..<10))
        XCTAssertEqual(pages.count, 3)
        XCTAssertEqual(pages.map(\.count), [4, 4, 2])
    }

    func testPageCountsMatchesPages() {
        let layout = GridLayout(columns: 3, rows: 2)
        XCTAssertEqual(layout.pageCounts(Array(0..<7)), [6, 1])
    }
}

final class GridNavigationTests: XCTestCase {
    private let pageCounts = [6, 6, 3] // 3x2 pages
    private let columns = 3

    func testLeftWithinPage() {
        let s = GridNavigation.move(.left, from: GridSelection(pageIndex: 0, itemIndex: 2), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 1))
    }

    func testLeftWrapsToPreviousPageEnd() {
        let s = GridNavigation.move(.left, from: GridSelection(pageIndex: 1, itemIndex: 0), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 5))
    }

    func testLeftStaysOnFirstPage() {
        let s = GridNavigation.move(.left, from: GridSelection(pageIndex: 0, itemIndex: 0), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 0))
    }

    func testRightWithinPage() {
        let s = GridNavigation.move(.right, from: GridSelection(pageIndex: 0, itemIndex: 4), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 5))
    }

    func testRightWrapsToNextPageStart() {
        let s = GridNavigation.move(.right, from: GridSelection(pageIndex: 0, itemIndex: 5), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 1, itemIndex: 0))
    }

    func testRightStaysOnLastPage() {
        let s = GridNavigation.move(.right, from: GridSelection(pageIndex: 2, itemIndex: 2), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 2, itemIndex: 2))
    }

    func testUpWithinPage() {
        let s = GridNavigation.move(.up, from: GridSelection(pageIndex: 1, itemIndex: 4), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 1, itemIndex: 1))
    }

    func testUpFromTopRowGoesToPreviousPageBottomRowSameColumn() {
        let s = GridNavigation.move(.up, from: GridSelection(pageIndex: 1, itemIndex: 1), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 4))
    }

    func testUpFromPartialPageGoesToPreviousPageBottomRowSameColumn() {
        // last page has 3 items (one row); item 1 is row 0 col 1, moving up goes to previous page row 1 col 1 = item 4
        let s = GridNavigation.move(.up, from: GridSelection(pageIndex: 2, itemIndex: 1), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 1, itemIndex: 4))
    }

    func testUpFromFirstRowOfFirstPageStays() {
        let s = GridNavigation.move(.up, from: GridSelection(pageIndex: 0, itemIndex: 0), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 0))
    }

    func testDownWithinPage() {
        let s = GridNavigation.move(.down, from: GridSelection(pageIndex: 0, itemIndex: 1), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 0, itemIndex: 4))
    }

    func testDownFromBottomRowGoesToNextPageTopRowSameColumn() {
        let s = GridNavigation.move(.down, from: GridSelection(pageIndex: 0, itemIndex: 4), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 1, itemIndex: 1))
    }

    func testDownMovesWithinPageFirst() {
        // middle page has 2 full rows; item 1 (row 0 col 1) moves down to item 4 (row 1 col 1), stays on page
        let s = GridNavigation.move(.down, from: GridSelection(pageIndex: 1, itemIndex: 1), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 1, itemIndex: 4))
    }

    func testDownFromLastPageStays() {
        let s = GridNavigation.move(.down, from: GridSelection(pageIndex: 2, itemIndex: 2), pageCounts: pageCounts, columns: columns)
        XCTAssertEqual(s, GridSelection(pageIndex: 2, itemIndex: 2))
    }

    func testClamp() {
        XCTAssertEqual(GridNavigation.clamp(GridSelection(pageIndex: 9, itemIndex: 9), pageCounts: pageCounts), GridSelection(pageIndex: 2, itemIndex: 2))
        XCTAssertEqual(GridNavigation.clamp(GridSelection(pageIndex: 0, itemIndex: -1), pageCounts: pageCounts), GridSelection(pageIndex: 0, itemIndex: 0))
        XCTAssertEqual(GridNavigation.clamp(.zero, pageCounts: []), .zero)
    }

    func testPage() {
        XCTAssertEqual(GridNavigation.page(1, pageCounts: pageCounts), GridSelection(pageIndex: 1, itemIndex: 0))
        XCTAssertEqual(GridNavigation.page(99, pageCounts: pageCounts), GridSelection(pageIndex: 2, itemIndex: 0))
    }
}
