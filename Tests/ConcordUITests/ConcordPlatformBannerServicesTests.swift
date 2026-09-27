import XCTest
@testable import ConcordUI

final class ConcordPlatformBannerServicesTests: XCTestCase {
    private final class TestPlatform: ConcordPlatform, ConcordPlatformBannerSupport {
        var displayed: [String] = []
        var pendingCompletion: ConcordBannerCompletion?
        var canDisplayBanner = true

        func displayPresentation(_ presentation: ConcordPresentation) {}
        func refreshPresentation(_ presentation: ConcordPresentation) {}

        func banner(_ text: String, completion: @escaping ConcordBannerCompletion) -> Bool {
            displayed.append(text)
            pendingCompletion = completion
            return true
        }

        func dismiss() {
            let completion = pendingCompletion
            pendingCompletion = nil
            completion?()
        }
    }

    func testBannerForwardsMessage() {
        let platform = TestPlatform()

        XCTAssertTrue(platform.banner("Hello"))
        XCTAssertEqual(platform.displayed, ["Hello"])
    }

    func testEmptyBannerIsRejected() {
        let platform = TestPlatform()

        XCTAssertFalse(platform.banner("   "))
        XCTAssertTrue(platform.displayed.isEmpty)
    }

    func testBannerCompletionRunsWhenPlatformDismisses() {
        let platform = TestPlatform()
        var completed = false

        XCTAssertTrue(platform.banner("Hello") { completed = true })
        XCTAssertFalse(completed)
        platform.dismiss()
        XCTAssertTrue(completed)
    }

    func testBannerListDisplaysSequentially() {
        let platform = TestPlatform()
        var completed = false

        XCTAssertTrue(platform.bannerList(["One", "Two", "Three"]) { completed = true })
        XCTAssertEqual(platform.displayed, ["One"])

        platform.dismiss()
        XCTAssertEqual(platform.displayed, ["One", "Two"])
        XCTAssertFalse(completed)

        platform.dismiss()
        XCTAssertEqual(platform.displayed, ["One", "Two", "Three"])
        XCTAssertFalse(completed)

        platform.dismiss()
        XCTAssertTrue(completed)
    }

    func testUnavailablePlatformReportsFalse() {
        let platform = TestPlatform()
        platform.canDisplayBanner = false

        XCTAssertFalse(platform.banner("Hello"))
        XCTAssertFalse(platform.bannerList(["One", "Two"]))
        XCTAssertTrue(platform.displayed.isEmpty)
    }
}
