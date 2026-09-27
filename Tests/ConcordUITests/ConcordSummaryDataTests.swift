import XCTest
@testable import ConcordUI

final class ConcordSummaryDataTests: XCTestCase {
    func testSummaryRetainsSemanticIconContent() {
        let summary = ConcordSummaryData(
            image: .icon(.information),
            title: "Enhanced Layout",
            description: "New auto-align rules."
        )

        XCTAssertEqual(summary.image, .icon(.information))
        XCTAssertEqual(summary.title, "Enhanced Layout")
        XCTAssertEqual(summary.description, "New auto-align rules.")
    }

    func testSummaryRetainsAssetContent() {
        let summary = ConcordSummaryData(
            image: .asset("custom-feature"),
            title: "Custom Themes",
            description: "Apply colors and text styles."
        )

        XCTAssertEqual(summary.image, .asset("custom-feature"))
    }
}
