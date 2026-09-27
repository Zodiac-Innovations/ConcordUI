import XCTest
@testable import ConcordUI

final class ConcordTextElementTests: XCTestCase {

    func testOwnedValueChangesAndCallsOnChangeAfterUpdate() {
        var callbackOld: String?
        var callbackNew: String?
        var valueSeenInsideCallback: String?
        var element: ConcordTextElement!

        element = ConcordTextElement(
            .normal,
            value: "Old",
            onChange: { oldValue, newValue in
                callbackOld = oldValue
                callbackNew = newValue
                valueSeenInsideCallback = element.value
            }
        )

        element.userChangedValue(to: "New")
        XCTAssertEqual(element.value, "New")
        XCTAssertEqual(callbackOld, "Old")
        XCTAssertEqual(callbackNew, "New")
        XCTAssertEqual(valueSeenInsideCallback, "New")
    }

    func testBoundValueWritesApplicationData() {
        var modelValue: String? = "First"
        let binding = ConcordBinding<String?>(get: { modelValue }, set: { modelValue = $0 })
        let element = ConcordTextElement(.normal, value: binding)
        element.userChangedValue(to: "Second")
        XCTAssertEqual(modelValue, "Second")
        XCTAssertEqual(element.value, "Second")
    }

    func testPasswordFlavorAndPresentationProperties() {
        let element = ConcordTextElement(.password, label: "Password", value: nil, placeholder: "Enter password")
        XCTAssertEqual(element.flavor, .password)
        XCTAssertEqual(element.label, "Password")
        XCTAssertNil(element.value)
        XCTAssertEqual(element.placeholder, "Enter password")
    }

    func testRegexStaysQuietUntilValidateThenUsesCustomError() {
        let element = ConcordTextElement(
            .normal,
            value: "123",
            regex: "^[A-Za-z]+$",
            regexErrorMessage: "Letters only"
        )

        XCTAssertEqual(element.validationState, .unvalidated)
        XCTAssertNil(element.errorText)
        XCTAssertFalse(element.validate())
        XCTAssertEqual(element.validationState, .invalid)
        XCTAssertEqual(element.errorText, "Letters only")

        element.userChangedValue(to: "Steve")
        XCTAssertTrue(element.validate())
        XCTAssertEqual(element.validationState, .valid)
        XCTAssertNil(element.errorText)
    }

    func testRegexUsesDefaultErrorMessageAfterValidation() {
        let element = ConcordTextElement(
            .normal,
            value: "123",
            regex: "^[A-Za-z]+$",
            regexErrorMessage: ""
        )
        XCTAssertNil(element.errorText)
        XCTAssertFalse(element.validate())
        XCTAssertEqual(element.errorText, ConcordString.invalidText)
    }

    func testOptionalEmptyTextSkipsRegex() {
        let element = ConcordTextElement(.normal, value: nil, regex: "^[A-Za-z]+$")
        XCTAssertTrue(element.validate())
        XCTAssertEqual(element.validationState, .valid)
    }

    func testReadOnlyPreventsUserChange() {
        let element = ConcordTextElement(.normal, value: "Original").readOnly()
        element.userChangedValue(to: "Changed")
        XCTAssertEqual(element.value, "Original")
    }
}
