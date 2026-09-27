import Testing
@testable import ConcordUI

private final class BoolValueBox {
    var value: Bool?
    init(_ value: Bool?) { self.value = value }
}

@Test("Boolean element preserves an owned optional value")
func boolElementOwnedOptionalValue() {
    let undecided = ConcordBoolElement(.checkbox, value: nil)
    let selected = ConcordBoolElement(.radio, value: true)

    #expect(undecided.value == nil)
    #expect(selected.value == true)
}

@Test("Boolean element writes through a binding")
func boolElementBindingWritesApplicationValue() {
    let box = BoolValueBox(nil)
    let binding = ConcordBinding<Bool?>(
        get: { box.value },
        set: { box.value = $0 }
    )
    let element = ConcordBoolElement(.toggle, value: binding)

    element.userChangedValue(to: true)

    #expect(box.value == true)
    #expect(element.value == true)
}

@Test("Boolean onChange runs after the bound value has changed")
func boolElementOnChangeRunsAfterBindingUpdate() {
    let box = BoolValueBox(false)
    let binding = ConcordBinding<Bool?>(
        get: { box.value },
        set: { box.value = $0 }
    )

    var receivedOld: Bool?
    var receivedNew: Bool?
    var modelValueDuringCallback: Bool?

    let element = ConcordBoolElement(
        .checkbox,
        value: binding,
        onChange: { oldValue, newValue in
            receivedOld = oldValue
            receivedNew = newValue
            modelValueDuringCallback = box.value
        }
    )

    element.userChangedValue(to: true)

    #expect(receivedOld == false)
    #expect(receivedNew == true)
    #expect(modelValueDuringCallback == true)
}

@Test("Boolean user change emits valueChanged action")
func boolElementEmitsValueChangedAction() {
    var received: ConcordActionEvent?
    let element = ConcordBoolElement(.radio, value: nil)
        .onAction(.valueChanged) { event in
            received = event
        }

    element.userChangedValue(to: false)

    #expect(received?.type == .valueChanged)
    #expect(received?.element === element)
    #expect(element.value == false)
}

@Test("Read-only Boolean element ignores user changes")
func readOnlyBoolElementIgnoresUserChanges() {
    var callbackCount = 0
    let element = ConcordBoolElement(
        .checkbox,
        value: nil,
        onChange: { _, _ in callbackCount += 1 }
    )
    .readOnly()

    element.userChangedValue(to: true)

    #expect(element.value == nil)
    #expect(callbackCount == 0)
}

@Test("Common form metadata is available on Boolean elements")
func boolElementUsesCommonFormMetadata() {
    let element = ConcordBoolElement(.checkbox, label: "Accept")
        .required()
        .help("Choose Yes or No")
        .error("A choice is required")
        .accessibility("Accept terms")
        .debug("acceptTerms")

    #expect(element.isRequired)
    #expect(element.helpText == "Choose Yes or No")
    #expect(element.errorText == "A choice is required")
    #expect(element.accessibilityText == "Accept terms")
    #expect(element.debugString == "acceptTerms")
}
