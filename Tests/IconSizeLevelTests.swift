import XCTest
@testable import EasyLaunchPad

final class IconSizeLevelTests: XCTestCase {
    func testFourLevels() {
        XCTAssertEqual(IconSizeLevel.allCases.count, 4)
        XCTAssertEqual(IconSizeLevel.allCases.map(\.title), ["小", "中", "大", "特大"])
    }

    func testMediumMatchesCurrentLayout() {
        // 中级别应保持现状布局常量（176/186）
        XCTAssertEqual(IconSizeLevel.medium.gridItemWidth, 176)
        XCTAssertEqual(IconSizeLevel.medium.gridItemHeight, 186)
        XCTAssertEqual(IconSizeLevel.medium.iconPoint, 96)
    }

    func testLevelsConsistency() {
        for level in IconSizeLevel.allCases {
            XCTAssertGreaterThan(level.ringPoint, level.iconPoint)
            XCTAssertGreaterThan(level.tileWidth, level.iconPoint)
            XCTAssertGreaterThan(level.gridItemWidth, level.tileWidth)
            XCTAssertGreaterThan(level.gridItemHeight, level.tileHeight)
            // 图块必须容纳图标 + 名称(34) + 间距(8)
            XCTAssertGreaterThanOrEqual(level.tileHeight, level.iconPoint + 42)
        }
    }

    func testGridLayoutWithLevels() {
        let size = CGSize(width: 2048, height: 1032)
        for level in IconSizeLevel.allCases {
            let layout = GridLayout.layout(
                for: size,
                itemWidth: level.gridItemWidth,
                itemHeight: level.gridItemHeight
            )
            XCTAssertGreaterThan(layout.columns, 0)
            XCTAssertGreaterThan(layout.rows, 0)
            XCTAssertGreaterThan(layout.perPage, 0)
        }
    }
}
