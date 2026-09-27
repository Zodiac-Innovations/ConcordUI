import XCTest
@testable import ConcordUI

final class ConcordABStackTests: XCTestCase {
    func testABStackKeepsNamedRegionsInABOrder() {
        let a = ConcordVStack([ConcordLabel("A")])
        let b = ConcordVStack([ConcordLabel("B")])
        let stack = ConcordABStack(a: a, b: b)

        XCTAssertEqual(stack.elements.count, 2)
        XCTAssertTrue(stack.a === a)
        XCTAssertTrue(stack.b === b)
        XCTAssertTrue(stack.elements[0] === a)
        XCTAssertTrue(stack.elements[1] === b)
    }

    func testPlatformClassificationRawValuesAreStable() {
        XCTAssertEqual(ConcordPlatformType.iOS.rawValue, "iOS")
        XCTAssertEqual(ConcordPlatformType.android.rawValue, "android")
        XCTAssertEqual(ConcordPlatformType.macOS.rawValue, "macOS")
        XCTAssertEqual(ConcordPlatformType.windows.rawValue, "windows")
        XCTAssertEqual(ConcordDeviceType.mobile.rawValue, "mobile")
        XCTAssertEqual(ConcordDeviceType.pad.rawValue, "pad")
        XCTAssertEqual(ConcordDeviceType.desktop.rawValue, "desktop")
        XCTAssertEqual(ConcordOrientation.landscape.rawValue, "landscape")
        XCTAssertEqual(ConcordOrientation.portrait.rawValue, "portrait")
        XCTAssertEqual(ConcordOrientation.none.rawValue, "none")
    }
}
