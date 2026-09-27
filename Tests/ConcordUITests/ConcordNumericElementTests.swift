import XCTest
@testable import ConcordUI

final class ConcordNumericElementTests: XCTestCase {

    func testIntOwnedValueClampsToRangeAndCallsOnChange() {
        var callbackOld: ConcordInt?
        var callbackNew: ConcordInt?
        let element = ConcordIntElement(.stepper, value: 5)
            .range(0...10)
            .onChange { oldValue, newValue in
                callbackOld = oldValue
                callbackNew = newValue
            }

        element.userChangedValue(to: 20)

        XCTAssertEqual(element.value, 10)
        XCTAssertEqual(callbackOld, 5)
        XCTAssertEqual(callbackNew, 10)
    }

    func testIntBindingWritesApplicationData() {
        var modelValue: ConcordInt? = 3
        let binding = ConcordBinding<ConcordInt?>(
            get: { modelValue },
            set: { modelValue = $0 }
        )
        let element = ConcordIntElement(.input, value: binding)

        element.userChangedValue(to: 9)

        XCTAssertEqual(modelValue, 9)
        XCTAssertEqual(element.value, 9)
    }

    func testFloatBindingAndStep() {
        var modelValue: ConcordFloat? = 1.5
        let binding = ConcordBinding<ConcordFloat?>(
            get: { modelValue },
            set: { modelValue = $0 }
        )
        let element = ConcordFloatElement(.combo, value: binding)
            .range(0.0...10.0, step: 0.25)

        element.userChangedValue(to: 2.75)

        XCTAssertEqual(modelValue, 2.75)
        XCTAssertEqual(element.value, 2.75)
        XCTAssertEqual(element.step, 0.25)
    }

    func testSliderDefaultRanges() {
        XCTAssertEqual(ConcordIntElement(.slider).effectiveRange, 0...100)
        XCTAssertEqual(ConcordFloatElement(.slider).effectiveRange, 0.0...100.0)
    }

    func testReadOnlyPreventsNumericChanges() {
        let integer = ConcordIntElement(.input, value: 4).readOnly()
        let floating = ConcordFloatElement(.input, value: 4.5).readOnly()

        integer.userChangedValue(to: 8)
        floating.userChangedValue(to: 8.5)

        XCTAssertEqual(integer.value, 4)
        XCTAssertEqual(floating.value, 4.5)
    }
}
