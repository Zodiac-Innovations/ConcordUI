import Foundation
import XCTest
@testable import ConcordUI

final class ConcordPlatformPrintServicesTests: XCTestCase {
    private final class TestPlatform: ConcordPlatform, ConcordPlatformFileSupport, ConcordPlatformPrintSupport {
        var retrievedData: Data?
        var printedText: String?
        var printedFont: ConcordFont?
        var printedImage: ConcordBitmapImage?
        var printedImageSize: Bool?
        var canPrintTextContent = true
        var canPrintImageContent = true

        var canRetrieveResources: Bool = true
        var canOpenResources: Bool = false
        var canShareResources: Bool = false

        func displayPresentation(_ presentation: ConcordPresentation) {}
        func refreshPresentation(_ presentation: ConcordPresentation) {}

        func resourceExists(name: String, type: ConcordResourceType) -> Bool { retrievedData != nil }
        func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? { retrievedData }
        func resourceOpen(name: String, type: ConcordResourceType) -> Bool { false }
        func resourceShare(name: String, type: ConcordResourceType) -> Bool { false }
        func shareTextContent(_ text: String) -> Bool { false }
        func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool { false }

        func printTextContent(_ text: String, font: ConcordFont) -> Bool {
            printedText = text
            printedFont = font
            return canPrintTextContent
        }

        func printImageContent(_ image: ConcordBitmapImage, size: Bool) -> Bool {
            printedImage = image
            printedImageSize = size
            return canPrintImageContent
        }
    }

    func testPrintCapabilitiesFollowPlatformSupport() {
        let platform = TestPlatform()
        XCTAssertTrue(platform.canPrintText)
        XCTAssertTrue(platform.canPrintImage)

        platform.canPrintTextContent = false
        platform.canPrintImageContent = false
        XCTAssertFalse(platform.canPrintText)
        XCTAssertFalse(platform.canPrintImage)
    }

    func testPrintTextUsesSystemFontByDefault() {
        let platform = TestPlatform()

        XCTAssertTrue(platform.printText("Hello"))
        XCTAssertEqual(platform.printedText, "Hello")
        XCTAssertEqual(platform.printedFont, .system)

        XCTAssertTrue(platform.printText("Code", font: .monospaced))
        XCTAssertEqual(platform.printedFont, .monospaced)
    }

    func testPrintFileTextRetrievesEmbeddedText() {
        let platform = TestPlatform()
        platform.retrievedData = Data("Embedded".utf8)

        XCTAssertTrue(platform.printFileText("Example.txt", font: .monospaced))
        XCTAssertEqual(platform.printedText, "Embedded")
        XCTAssertEqual(platform.printedFont, .monospaced)
    }

    func testPrintImageDefaultsToSizingToSinglePage() {
        let platform = TestPlatform()
        let image = ConcordBitmapImage(
            data: Data([1, 2, 3]),
            format: .png,
            pixelWidth: 100,
            pixelHeight: 50
        )

        XCTAssertTrue(platform.printImage(image))
        XCTAssertEqual(platform.printedImage?.pixelWidth, 100)
        XCTAssertEqual(platform.printedImageSize, true)

        XCTAssertTrue(platform.printImage(image, size: false))
        XCTAssertEqual(platform.printedImageSize, false)
    }

    func testPrintFileImageRetrievesBitmap() {
        let platform = TestPlatform()
        let bytes: [UInt8] = [
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
            0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x00, 0x20,
            0x00, 0x00, 0x00, 0x10
        ]
        platform.retrievedData = Data(bytes)

        XCTAssertTrue(platform.printFileImage("Example.png"))
        XCTAssertEqual(platform.printedImage?.pixelWidth, 32)
        XCTAssertEqual(platform.printedImage?.pixelHeight, 16)
        XCTAssertEqual(platform.printedImageSize, true)
    }
}
