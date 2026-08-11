import XCTest
@testable import EasyLaunchPad

final class VersionTests: XCTestCase {
    func testParseBasic() {
        XCTAssertEqual(Version("0.1.0"), Version(major: 0, minor: 1, patch: 0))
        XCTAssertEqual(Version("1.2.3"), Version(major: 1, minor: 2, patch: 3))
    }

    func testParseWithVPrefix() {
        XCTAssertEqual(Version("v0.1.0"), Version(major: 0, minor: 1, patch: 0))
        XCTAssertEqual(Version("v2.0.0"), Version(major: 2, minor: 0, patch: 0))
    }

    func testParseMissingPatch() {
        XCTAssertEqual(Version("0.1"), Version(major: 0, minor: 1, patch: 0))
    }

    func testParseInvalid() {
        XCTAssertNil(Version(""))
        XCTAssertNil(Version("abc"))
        XCTAssertNil(Version("1.x.3"))
    }

    func testCompare() {
        XCTAssertLessThan(Version("0.1.0")!, Version("0.2.0")!)
        XCTAssertLessThan(Version("0.2.0")!, Version("0.2.1")!)
        XCTAssertLessThan(Version("1.9.9")!, Version("2.0.0")!)
        XCTAssertEqual(Version("0.1.0")!, Version("0.1.0")!)
        XCTAssertGreaterThan(Version("0.3.0")!, Version("0.2.9")!)
    }

    func testDescription() {
        XCTAssertEqual(Version("v1.2.3")!.description, "1.2.3")
    }
}
