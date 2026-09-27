import Testing
@testable import ConcordUI

@Test("String selection binds selected text and reports index")
func stringSelectionBinding() {
    var value: String? = "Green"
    let binding = ConcordBinding<String?>(get: { value }, set: { value = $0 })
    var changedIndex: Int?
    var changedText: String?
    let element = ConcordStringSelectionElement(.popup, items: ["Red", "Green", "Blue"], value: binding)
        .onChange { index, text in changedIndex = index; changedText = text }

    #expect(element.selectedIndex == 1)
    element.userSelected(index: 2)
    #expect(value == "Blue")
    #expect(changedIndex == 2)
    #expect(changedText == "Blue")
}

@Test("Index selection binds array position")
func indexSelectionBinding() {
    var value: ConcordInt? = 0
    let binding = ConcordBinding<ConcordInt?>(get: { value }, set: { value = $0 })
    let element = ConcordIndexSelectionElement(.segmented, items: ["Small", "Medium", "Large"], value: binding)

    element.userSelected(index: 2)
    #expect(value == 2)
    #expect(element.displayText(at: 2) == "Large")
}

@Test("String tagged selection binds semantic tag independently of position")
func stringTaggedSelectionBinding() {
    let items = [
        ConcordStringTaggedItem("California", tag: "CA"),
        ConcordStringTaggedItem("Maryland", tag: "MD")
    ]
    let element = ConcordStringTaggedSelectionElement(.radio, items: items, value: "MD").showTag()

    #expect(element.selectedIndex == 1)
    #expect(element.displayText(at: 0) == "California (CA)")
    element.userSelected(index: 0)
    #expect(element.value == "CA")
}

@Test("Integer tagged selection supports one-based semantic values")
func intTaggedSelectionBinding() {
    let items = [
        ConcordIntTaggedItem("January", tag: 1),
        ConcordIntTaggedItem("February", tag: 2),
        ConcordIntTaggedItem("March", tag: 3)
    ]
    var callbackTag: ConcordInt?
    let element = ConcordIntTaggedSelectionElement(.spinner, items: items, value: 2)
        .onChange { _, _, tag in callbackTag = tag }

    #expect(element.selectedIndex == 1)
    element.userSelected(index: 2)
    #expect(element.value == 3)
    #expect(callbackTag == 3)
}

@Test("Tagged selections hide tags by default")
func taggedSelectionShowTagDefault() {
    let item = ConcordIntTaggedItem("December", tag: 12)
    let element = ConcordIntTaggedSelectionElement(.popup, items: [item], value: 12)

    #expect(element.showsTag == false)
    #expect(element.displayText(at: 0) == "December")
    element.showTag()
    #expect(element.displayText(at: 0) == "December (12)")
}

@Test("Required selection validates only when requested")
func requiredSelectionValidation() {
    let element = ConcordStringSelectionElement(.popup, items: ["A", "B"], value: nil).required()

    #expect(element.validationState == .unvalidated)
    #expect(element.validate() == false)
    #expect(element.validationState == .invalid)
    element.userSelected(index: 0)
    #expect(element.value == "A")
}
