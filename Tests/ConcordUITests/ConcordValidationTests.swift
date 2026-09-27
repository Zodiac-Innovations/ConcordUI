import XCTest
@testable import ConcordUI

private final class ValidationTestPlatform: ConcordPlatform {
    var currentPresentation: ConcordPresentation?

    func displayPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }

    func refreshPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }
}

final class ConcordValidationTests: XCTestCase {

    func testRequiredTextStaysQuietUntilPresentationValidation() {
        let field = ConcordTextElement(.normal, label: "Name", value: nil).required()
        let presentation = ConcordPresentation {
            ConcordVStack([field])
        }
        let app = ConcordApplication(platform: ValidationTestPlatform())
        app.mainVenue.displayPresentation(presentation)

        XCTAssertEqual(field.validationState, .unvalidated)
        XCTAssertNil(field.errorText)
        XCTAssertFalse(presentation.validationIsActive)

        XCTAssertFalse(presentation.validate())
        XCTAssertTrue(presentation.validationIsActive)
        XCTAssertEqual(field.validationState, .invalid)
        XCTAssertEqual(field.errorText, ConcordString.required)
    }

    func testChangedElementRevalidatesAfterValidationActivated() {
        let platform = ValidationTestPlatform()
        let field = ConcordTextElement(.normal, label: "Name", value: nil).required()
        let presentation = ConcordPresentation {
            ConcordVStack([field])
        }
        let app = ConcordApplication(platform: platform)
        app.mainVenue.displayPresentation(presentation)

        XCTAssertFalse(presentation.validate())
        field.userChangedValue(to: "Steve")

        XCTAssertEqual(field.validationState, .valid)
        XCTAssertNil(field.errorText)
    }

    func testRequiredBoolIntAndFloat() {
        let bool = ConcordBoolElement(.checkbox, value: nil).required()
        let int = ConcordIntElement(.input, value: nil).required()
        let float = ConcordFloatElement(.input, value: nil).required()
        let presentation = ConcordPresentation {
            ConcordVStack([bool, int, float])
        }
        let app = ConcordApplication(platform: ValidationTestPlatform())
        app.mainVenue.displayPresentation(presentation)

        XCTAssertFalse(presentation.validate())
        XCTAssertEqual(bool.validationState, .invalid)
        XCTAssertEqual(int.validationState, .invalid)
        XCTAssertEqual(float.validationState, .invalid)
    }

    func testResetValidationReturnsElementsToQuietState() {
        let field = ConcordTextElement(.normal, value: nil).required()
        let presentation = ConcordPresentation {
            ConcordVStack([field])
        }
        let app = ConcordApplication(platform: ValidationTestPlatform())
        app.mainVenue.displayPresentation(presentation)

        XCTAssertFalse(presentation.validate())
        presentation.resetValidation()

        XCTAssertFalse(presentation.validationIsActive)
        XCTAssertEqual(field.validationState, .unvalidated)
        XCTAssertNil(field.errorText)
    }

    func testApplicationPresentationDefaultsAreCopiedDownward() {
        let field = ConcordTextElement(.normal, value: nil).required()
        let presentation = ConcordPresentation {
            ConcordVStack([field])
        }
        let app = ConcordApplication(
            platform: ValidationTestPlatform(),
            requiredIndicator: .requiredText,
            invalidIndicator: .redBorderAndErrorText
        )

        app.mainVenue.displayPresentation(presentation)

        XCTAssertEqual(field.requiredIndicator, .requiredText)
        XCTAssertEqual(field.invalidIndicator, .redBorderAndErrorText)
    }
}
