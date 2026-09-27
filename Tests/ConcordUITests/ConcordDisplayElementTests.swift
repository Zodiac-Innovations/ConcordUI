import Foundation
import Testing
@testable import ConcordUI

@Test("Standard icon image stores semantic image data")
func standardIconImageStoresData() {
    let image = ConcordImage.icon(.settings)
        .accessibility("Settings")

    #expect(image.imageData == .icon(.settings))
    #expect(image.accessibilityText == "Settings")
}

@Test("Named image stores asset image data")
func namedImageStoresAssetData() {
    let image = ConcordImage("Logo")

    #expect(image.imageData == .asset("Logo"))
}

@Test("Explicit ConcordImageData can create an image")
func explicitImageDataCreatesImage() {
    let data = ConcordImageData.icon(.information)
    let image = ConcordImage(data)

    #expect(image.imageData == data)
}

@Test("Font capability supports abstract family and helpers")
func fontCapabilityStoresFamily() {
    let label = ConcordLabel("Code").monospacedFont()
    let button = ConcordButton("System") {}.systemFont()
    let text = ConcordTextElement(.normal, label: "Value", value: "abc").font(.monospaced)

    #expect(label.font == .monospaced)
    #expect(button.font == .system)
    #expect(text.font == .monospaced)
}

@Test("Progress clamps values to normalized range")
func progressClampsValues() {
    let progress = ConcordProgressElement(.bar, label: "Loading", value: 2)

    #expect(progress.value == 1)
    progress.progress(-1)
    #expect(progress.value == 0)
    progress.progress(0.5)
    #expect(progress.value == 0.5)
}

@Test("Spinner progress retains label")
func spinnerProgressRetainsLabel() {
    let progress = ConcordProgressElement(.spinner, label: "Working")

    #expect(progress.flavor == .spinner)
    #expect(progress.label == "Working")
}

private final class EmbeddedResourceTestPlatform: ConcordPlatform {
    let textData: Data?
    let imageData: Data?

    init(text: String? = nil, imageData: Data? = nil) {
        self.textData = text?.data(using: .utf8)
        self.imageData = imageData
    }

    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
        switch type {
        case .text: return textData
        case .image: return imageData
        case .pdf, .custom: return nil
        }
    }

    func displayPresentation(_ presentation: ConcordPresentation) {}
    func refreshPresentation(_ presentation: ConcordPresentation) {}
}

@Test("Text resource modifier retrieves embedded text")
func textResourceModifierRetrievesText() {
    let platform = EmbeddedResourceTestPlatform(text: "Embedded text")
    let label = ConcordLabel("Original").resourceText("welcome", using: platform)

    #expect(label.text == "Embedded text")
}

@Test("Editable text resource modifier retrieves embedded text")
func editableTextResourceModifierRetrievesText() {
    let platform = EmbeddedResourceTestPlatform(text: "Embedded value")
    let element = ConcordTextElement(value: "Original")
        .resourceText("initial-value", using: platform)

    #expect(element.value == "Embedded value")
}

@Test("Text resource modifier preserves text when retrieval fails")
func textResourceModifierPreservesTextWhenMissing() {
    let platform = EmbeddedResourceTestPlatform()
    let label = ConcordLabel("Original").resourceText("missing", using: platform)

    #expect(label.text == "Original")
}

@Test("Image resource modifier selects a readable embedded image")
func imageResourceModifierSelectsEmbeddedImage() {
    let platform = EmbeddedResourceTestPlatform(imageData: Data([0x89, 0x50, 0x4E, 0x47]))
    let image = ConcordImage.icon(.app).resourceImage("logo", using: platform)

    #expect(image.imageData == .asset("logo"))
}

@Test("Image resource modifier preserves image when retrieval fails")
func imageResourceModifierPreservesImageWhenMissing() {
    let platform = EmbeddedResourceTestPlatform()
    let image = ConcordImage.icon(.app).resourceImage("missing", using: platform)

    #expect(image.imageData == .icon(.app))
}

@Test func buttonFlavorsAndIcon() {
    let rounded = ConcordButton("Rounded")
    #expect(rounded.flavor == .roundedRectangle)
    #expect(rounded.icon == nil)

    let text = ConcordButton("Text", flavor: .text)
    #expect(text.flavor == .text)

    let icon = ConcordButton(icon: .home, accessibilityLabel: "Home")
    #expect(icon.flavor == .icon)
    #expect(icon.icon == .home)
    #expect(icon.title == "Home")
    #expect(icon.accessibilityText == "Home")
}

@Test func buttonRolesUseFluentModifiers() {
    let normal = ConcordButton("Normal")
    #expect(normal.role == .normal)

    let defaultButton = ConcordButton("Save").defaultAction()
    #expect(defaultButton.role == .defaultAction)

    let cancelButton = ConcordButton("Cancel").cancelAction()
    #expect(cancelButton.role == .cancel)

    let destructiveButton = ConcordButton("Delete").destructiveAction()
    #expect(destructiveButton.role == .destructive)
}

@Test("Platform hints are available on every element")
func platformHintsAreAvailableOnEveryElement() {
    let label = ConcordLabel("Native")
        .hint(platform: .android, number: 10)
        .hint(platform: .iOS, number: 20, param: 3)

    #expect(label.platformHints.count == 2)
    #expect(label.hint(for: .android, number: 10)?.param == nil)
    #expect(label.hint(for: .iOS, number: 20)?.param == 3)
}

@Test("A platform hint replaces the same platform and number")
func platformHintReplacesMatchingHint() {
    let button = ConcordButton("Action")
        .hint(platform: .windows, number: 7, param: 1)
        .hint(platform: .windows, number: 7, param: 2)
        .hint(platform: .macOS, number: 7, param: 3)

    #expect(button.platformHints.count == 2)
    #expect(button.hint(for: .windows, number: 7)?.param == 2)
    #expect(button.hint(for: .macOS, number: 7)?.param == 3)
}

@Test("Boolean control side is an optional fluent override")
func booleanControlSideOverride() {
    let platformDefault = ConcordBoolElement(.toggle, label: "Default")
    let right = ConcordBoolElement(.toggle, label: "Right").controlOnRight()
    let left = ConcordBoolElement(.checkbox, label: "Left").controlOnRight(false)

    #expect(platformDefault.isControlOnRight == nil)
    #expect(right.isControlOnRight == true)
    #expect(left.isControlOnRight == false)
}
