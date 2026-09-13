import XCTest
@testable import EasyLaunchPad

final class CatalogOrderTests: XCTestCase {
    private func app(_ id: String) -> AppItem {
        AppItem(id: id, name: id, url: nil)
    }

    func testApplyingOrderReordersKnownApps() {
        let apps = [app("a"), app("b"), app("c")]
        let result = AppCatalog.applyingOrder(apps, orderIDs: ["c", "a", "b"])
        XCTAssertEqual(result.map(\.id), ["c", "a", "b"])
    }

    func testApplyingOrderAppendsUnknownApps() {
        // 新安装的应用（顺序中不存在）保持原相对顺序追加在末尾
        let apps = [app("a"), app("b"), app("c")]
        let result = AppCatalog.applyingOrder(apps, orderIDs: ["b"])
        XCTAssertEqual(result.map(\.id), ["b", "a", "c"])
    }

    func testApplyingOrderIgnoresStaleIDs() {
        // 已卸载应用残留的顺序 ID 不产生空位
        let apps = [app("a"), app("b")]
        let result = AppCatalog.applyingOrder(apps, orderIDs: ["gone", "b", "a"])
        XCTAssertEqual(result.map(\.id), ["b", "a"])
    }

    func testApplyingOrderEmptyOrderKeepsOriginal() {
        let apps = [app("b"), app("a")]
        XCTAssertEqual(AppCatalog.applyingOrder(apps, orderIDs: []).map(\.id), ["b", "a"])
    }

    func testApplyingOrderSingleAppKeepsOriginal() {
        let apps = [app("a")]
        XCTAssertEqual(AppCatalog.applyingOrder(apps, orderIDs: ["a"]).map(\.id), ["a"])
    }
}
