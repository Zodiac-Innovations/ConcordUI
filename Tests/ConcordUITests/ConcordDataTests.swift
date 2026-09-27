import Foundation
import XCTest
@testable import ConcordUI

final class ConcordDataTests: XCTestCase {
    func testStringDataClonesAndFillsIndependently() {
        let original = ConcordStringData("Original")
        let clone = original.clone()

        XCTAssertFalse(original === clone)
        XCTAssertEqual(clone.value, "Original")

        clone.value = "Edited"
        XCTAssertEqual(original.value, "Original")

        original.fill(from: clone)
        XCTAssertEqual(original.value, "Edited")
        XCTAssertEqual(original.description, "Edited")
    }

    func testScalarDataUsesConcordNumericAliases() {
        let bool = ConcordBoolData(true)
        let integer = ConcordIntData(42)
        let floating = ConcordFloatData(3.5)

        let _: Int = integer.value
        let _: ConcordFloat = floating.value

        XCTAssertEqual(bool.clone().value, true)
        XCTAssertEqual(integer.clone().value, 42)
        XCTAssertEqual(floating.clone().value, 3.5)
    }

    func testAllSingleValueDataObjectsAreCodable() throws {
        try assertRoundTrip(ConcordStringData("String")) { $0.value == "String" }
        try assertRoundTrip(ConcordBoolData(true)) { $0.value }
        try assertRoundTrip(ConcordIntData(7)) { $0.value == 7 }
        try assertRoundTrip(ConcordFloatData(2.5)) { $0.value == 2.5 }
    }

    func testBitmapImageStoresPortableDataAndDimensions() throws {
        let source = Data([0x89, 0x50, 0x4E, 0x47])
        let image = ConcordBitmapImage(
            data: source,
            format: .png,
            pixelWidth: 1200,
            pixelHeight: 600
        )

        XCTAssertEqual(image.data, source)
        XCTAssertEqual(image.format, .png)
        XCTAssertEqual(image.pixelWidth, 1200)
        XCTAssertEqual(image.pixelHeight, 600)
        XCTAssertEqual(image.aspectRatio, 2.0)

        let encoded = try JSONEncoder().encode(image)
        let decoded = try JSONDecoder().decode(ConcordBitmapImage.self, from: encoded)
        XCTAssertEqual(decoded.data, source)
        XCTAssertEqual(decoded.format, .png)
        XCTAssertEqual(decoded.pixelWidth, 1200)
        XCTAssertEqual(decoded.pixelHeight, 600)
        XCTAssertEqual(decoded.aspectRatio, 2.0)
    }

    func testPDFDataStoresPortableDataAndRoundTrips() throws {
        let source = Data([0x25, 0x50, 0x44, 0x46])
        let pdf = ConcordPDFData(data: source)

        XCTAssertEqual(pdf.data, source)

        let encoded = try JSONEncoder().encode(pdf)
        let decoded = try JSONDecoder().decode(ConcordPDFData.self, from: encoded)
        XCTAssertEqual(decoded.data, source)
    }

    func testQADataSupportsExplicitCreationAndDefaultsAccess() {
        let question = ConcordQAData(
            question: "How do I save?",
            answer: "Choose File > Save."
        )
        let list = ConcordQAListData(title: "", questions: [question])

        XCTAssertEqual(question.question, "How do I save?")
        XCTAssertEqual(question.answer, "Choose File > Save.")
        XCTAssertTrue(question.access.isEmpty)
        XCTAssertEqual(list.title, "")
        XCTAssertEqual(list.questions, [question])
    }

    func testQADataDecodesFromJSONText() throws {
        let itemJSON = """
        {
          "question": "Where is the guide?",
          "answer": "Open the documentation.",
          "access": [
            {
              "title": "User Guide",
              "link": "https://example.com/guide"
            }
          ]
        }
        """
        let item = try ConcordQAData(json: itemJSON)

        XCTAssertEqual(item.question, "Where is the guide?")
        XCTAssertEqual(item.answer, "Open the documentation.")
        XCTAssertEqual(item.access.first?.title, "User Guide")
        XCTAssertEqual(item.access.first?.link, "https://example.com/guide")

        let listJSON = """
        {
          "title": "Getting Started",
          "questions": [
            {
              "question": "How do I begin?",
              "answer": "Create a document."
            }
          ]
        }
        """
        let list = try ConcordQAListData(json: listJSON)

        XCTAssertEqual(list.title, "Getting Started")
        XCTAssertEqual(list.questions.count, 1)
        XCTAssertTrue(list.questions[0].access.isEmpty)
    }

    func testQAListJSONDefaultsMissingTitleAndQuestions() throws {
        let list = try ConcordQAListData(json: "{}")

        XCTAssertEqual(list.title, "")
        XCTAssertTrue(list.questions.isEmpty)
        XCTAssertThrowsError(
            try ConcordQAData(json: #"{"question":" ","answer":"Answer"}"#)
        )
    }

    private func assertRoundTrip<Value: ConcordDataProtocol>(
        _ value: Value,
        assertion: (Value) -> Bool
    ) throws {
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(Value.self, from: encoded)
        XCTAssertTrue(assertion(decoded))
    }
}
