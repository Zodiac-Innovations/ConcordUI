import Foundation
import XCTest
@testable import ConcordUI

final class ConcordDateTimeElementTests: XCTestCase {
    func testDateBindingAndOnChange() {
        var model: Date? = Date(timeIntervalSince1970: 100)
        let binding = ConcordBinding<Date?>(get: { model }, set: { model = $0 })
        var observed: Date?
        let element = ConcordDateElement(.picker, label: "Date", value: binding)
            .onChange { _, newValue in observed = newValue }

        let changed = Date(timeIntervalSince1970: 200)
        element.userChangedValue(to: changed)

        XCTAssertEqual(model, changed)
        XCTAssertEqual(observed, changed)
    }

    func testDateRangeClampsValue() {
        let lower = Date(timeIntervalSince1970: 100)
        let upper = Date(timeIntervalSince1970: 200)
        let element = ConcordDateElement(.components, value: lower).range(lower...upper)

        element.userChangedValue(to: Date(timeIntervalSince1970: 300))
        XCTAssertEqual(element.value, upper)
    }

    func testTimeAndDateTimeUseFoundationDate() {
        let value = Date(timeIntervalSince1970: 1234)
        XCTAssertEqual(ConcordTimeElement(.picker, value: value).value, value)
        XCTAssertEqual(ConcordDateTimeElement(.components, value: value).value, value)
    }

    func testRequiredDateValidation() {
        let element = ConcordDateElement(.picker, value: nil).required()
        XCTAssertFalse(element.validate())
        XCTAssertEqual(element.errorText, ConcordString.required)
        element.value = Date()
        XCTAssertTrue(element.validate())
    }
}
