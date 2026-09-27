import Foundation
import XCTest
@testable import ConcordUI

final class ConcordPlatformFileServicesTests: XCTestCase {
    private final class TestPlatform: ConcordPlatform, ConcordPlatformFileSupport {
        var retrievedData: Data?
        var retrievedType: ConcordResourceType?
        var openedType: ConcordResourceType?
        var sharedType: ConcordResourceType?
        var sharedText: String?
        var sharedData: Data?
        var sharedFilename: String?
        var sharedMimeType: String?

        var canRetrieveResources: Bool = true
        var canOpenResources: Bool = true
        var canShareResources: Bool = true

        func displayPresentation(_ presentation: ConcordPresentation) {}
        func refreshPresentation(_ presentation: ConcordPresentation) {}

        func resourceExists(name: String, type: ConcordResourceType) -> Bool {
            retrievedData != nil
        }

        func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
            retrievedType = type
            return retrievedData
        }

        func resourceOpen(name: String, type: ConcordResourceType) -> Bool {
            openedType = type
            return canOpenResources
        }

        func resourceShare(name: String, type: ConcordResourceType) -> Bool {
            sharedType = type
            return canShareResources
        }

        func shareTextContent(_ text: String) -> Bool {
            sharedText = text
            return canShareResources
        }

        func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool {
            sharedData = data
            sharedFilename = filename
            sharedMimeType = mimeType
            return canShareResources
        }
    }

    func testTypedCapabilitiesFollowPlatformFileSupport() {
        let platform = TestPlatform()
        XCTAssertTrue(platform.canRetrieveData)
        XCTAssertTrue(platform.canRetrieveText)
        XCTAssertTrue(platform.canRetrieveBitmap)
        XCTAssertTrue(platform.canRetrievePDF)
        XCTAssertTrue(platform.canOpenText)
        XCTAssertTrue(platform.canSharePDF)

        platform.canShareResources = false
        XCTAssertFalse(platform.canShareText)
        XCTAssertFalse(platform.canShareBitmap)
    }

    func testTextFilenameNormalizesExtension() {
        let platform = TestPlatform()
        platform.retrievedData = Data("Hello".utf8)

        XCTAssertEqual(platform.retrieveTextFile("Greeting.txt"), "Hello")
        XCTAssertEqual(platform.retrievedType, .text)
        XCTAssertNil(platform.retrieveTextFile("Greeting.pdf"))
        XCTAssertNil(platform.retrieveTextFile("folder/Greeting.txt"))
    }

    func testPDFFileReturnsPortablePDF() {
        let platform = TestPlatform()
        let data = Data("%PDF-1.4".utf8)
        platform.retrievedData = data

        XCTAssertEqual(platform.retrievePDFFile("Report.pdf")?.data, data)
        XCTAssertEqual(platform.retrievedType, .pdf)
    }

    func testRawDataFileUsesCustomExtension() {
        let platform = TestPlatform()
        let data = Data([1, 2, 3])
        platform.retrievedData = data

        XCTAssertEqual(platform.retrieveDataFile("Payload.bin"), data)
        XCTAssertEqual(platform.retrievedType, .custom("bin"))
    }

    func testSharingSeparatesValuesFromEmbeddedFiles() {
        let platform = TestPlatform()

        XCTAssertTrue(platform.shareText("Hello"))
        XCTAssertEqual(platform.sharedText, "Hello")

        XCTAssertTrue(platform.shareTextFile("Greeting.txt"))
        XCTAssertEqual(platform.sharedType, .text)

        let pdf = ConcordPDF(data: Data("%PDF".utf8))
        XCTAssertTrue(platform.sharePDF(pdf))
        XCTAssertEqual(platform.sharedFilename, "SharedDocument.pdf")
        XCTAssertEqual(platform.sharedMimeType, "application/pdf")
    }

    func testBitmapCanReadPNGDimensions() {
        let bytes: [UInt8] = [
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
            0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x00, 0x20,
            0x00, 0x00, 0x00, 0x10
        ]

        let bitmap = ConcordBitmapImage(data: Data(bytes))
        XCTAssertEqual(bitmap?.format, .png)
        XCTAssertEqual(bitmap?.pixelWidth, 32)
        XCTAssertEqual(bitmap?.pixelHeight, 16)
    }
}
