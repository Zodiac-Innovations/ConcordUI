import XCTest
@testable import ConcordUI

final class ConcordWorkStackTests: XCTestCase {
    func testWorkStackKeepsMainAndBottomRegionsInOrder() {
        let title = ConcordLabel("Title")
        let action = ConcordButton("Done")
        let stack = ConcordWorkStack([title], bottom: [action])

        XCTAssertEqual(stack.elements.count, 2)
        XCTAssertTrue(stack.elements[0] === stack.main)
        XCTAssertTrue(stack.elements[1] === stack.bottom)
        XCTAssertTrue(stack.main.elements.first === title)
        XCTAssertTrue(stack.bottom.elements.first === action)
        XCTAssertEqual(stack.bottom.horizontalJustification, .right)
        XCTAssertEqual(stack.bottomHeight, ConcordWorkStack.defaultBottomHeight)
    }

    func testWorkStackRetainsEmptyBottomRegion() {
        let stack = ConcordWorkStack([ConcordLabel("Content")])

        XCTAssertEqual(stack.bottom.elements.count, 0)
        XCTAssertEqual(stack.elements.count, 2)
        XCTAssertEqual(stack.edge, 0)
        XCTAssertEqual(stack.spacing, 0)
    }
}
