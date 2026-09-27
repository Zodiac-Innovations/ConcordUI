import XCTest
@testable import ConcordUI

final class ConcordElementCapabilityTests: XCTestCase {

    func testBooleanTwoStateConvenienceNames() {
        let element = ConcordBoolElement(.radio)

        element.nameYesNo()
        XCTAssertEqual(element.trueName, "Yes")
        XCTAssertEqual(element.falseName, "No")

        element.nameOnOff()
        XCTAssertEqual(element.firstName, "On")
        XCTAssertEqual(element.secondName, "Off")
    }

    func testNumericRangeAndStepCapability() {
        let integer = ConcordIntElement(.slider)
            .range(0...100, step: 5)
        let floating = ConcordFloatElement(.slider)
            .range(0.0...1.0, step: 0.05)

        XCTAssertEqual(integer.range, 0...100)
        XCTAssertEqual(integer.step, 5)
        XCTAssertEqual(floating.range, 0.0...1.0)
        XCTAssertEqual(floating.step, 0.05)
    }

    func testBindableReportsOwnedAndBoundValues() {
        let owned = ConcordTextElement(.normal, value: "Owned")
        XCTAssertFalse(owned.isBound)

        var model: String? = "Bound"
        let binding = ConcordBinding<String?>(
            get: { model },
            set: { model = $0 }
        )
        let bound = ConcordTextElement(.normal, value: binding)
        XCTAssertTrue(bound.isBound)

        bound.value = "Changed"
        XCTAssertEqual(model, "Changed")
    }

    func testCapabilityModifiersRemainAvailableOnSupportedTypes() {
        let text = ConcordTextElement(.normal, label: "Name")
            .required()
            .help("Enter a name")
            .boxed(cornerRadius: 4)
            .fillWidth()
            .leftJustified()
            .accessibility("Name field")
            .debug("text-test")
            .readOnly()

        XCTAssertTrue(text.isRequired)
        XCTAssertEqual(text.helpText, "Enter a name")
        XCTAssertNotNil(text.boxStyle)
        XCTAssertEqual(text.horizontalJustification, .left)
        XCTAssertEqual(text.accessibilityText, "Name field")
        XCTAssertEqual(text.debugString, "text-test")
        XCTAssertTrue(text.isReadOnly)
    }

    func testButtonIsActionableAndReadOnlyButNotEditableValue() {
        let button = ConcordButton("Save").readOnly()
        XCTAssertTrue(button.isReadOnly)

        func acceptsActionable<T: ConcordActionable>(_ value: T) { _ = value }
        func acceptsReadOnly<T: ConcordReadOnly>(_ value: T) { _ = value }

        acceptsActionable(button)
        acceptsReadOnly(button)
    }

    func testValidationConvenienceState() {
        let element = ConcordIntElement(.input, value: nil).required()

        XCTAssertTrue(element.isUnvalidated)
        XCTAssertFalse(element.validate())
        XCTAssertTrue(element.isInvalid)
        XCTAssertFalse(element.isValid)

        element.value = 42
        XCTAssertTrue(element.validate())
        XCTAssertTrue(element.isValid)
    }
}
