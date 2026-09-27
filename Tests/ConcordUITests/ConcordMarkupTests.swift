import Foundation
import Testing
@testable import ConcordUI

private final class TestMarkup: ConcordMarkupProtocol {
    var commands: [String] = []

    func beginDocument(style: String?) { commands.append("beginDocument") }
    func endDocument() { commands.append("endDocument") }
    func beginSection(style: String?) { commands.append("beginSection") }
    func endSection() { commands.append("endSection") }
    func beginHeading(level: Int, style: String?) { commands.append("beginHeading:\(level)") }
    func endHeading() { commands.append("endHeading") }
    func beginParagraph(style: String?) { commands.append("beginParagraph") }
    func endParagraph() { commands.append("endParagraph") }
    func addText(_ text: String, style: String?) { commands.append("text:\(text)") }
    func addLineBreak() { commands.append("lineBreak") }
    func beginStrong(style: String?) { commands.append("beginStrong") }
    func endStrong() { commands.append("endStrong") }
    func beginEmphasis(style: String?) { commands.append("beginEmphasis") }
    func endEmphasis() { commands.append("endEmphasis") }
    func beginLink(destination: String, style: String?) { commands.append("beginLink:\(destination)") }
    func endLink() { commands.append("endLink") }
    func beginList(kind: ConcordMarkupListKind, start: Int?, style: String?) { commands.append("beginList:\(kind.rawValue)") }
    func endList() { commands.append("endList") }
    func beginListItem(style: String?) { commands.append("beginListItem") }
    func endListItem() { commands.append("endListItem") }
    func addImage(_ image: ConcordImageData, alternateText: String?, style: String?) { commands.append("image") }
    func beginBlockQuote(style: String?) { commands.append("beginBlockQuote") }
    func endBlockQuote() { commands.append("endBlockQuote") }
    func beginCode(language: String?, style: String?) { commands.append("beginCode") }
    func endCode() { commands.append("endCode") }
    func beginPreformatted(style: String?) { commands.append("beginPreformatted") }
    func endPreformatted() { commands.append("endPreformatted") }
    func addHorizontalRule(style: String?) { commands.append("horizontalRule") }
}

@Test("Markup closure targets protocol implementation")
func markupClosureTargetsProtocolImplementation() {
    let content: ConcordMarkupClosure = { markup in
        markup.document {
            $0.heading("ConcordUI", level: 1)
            $0.paragraph {
                $0.text("Portable ")
                $0.strong("Swift")
            }
        }
    }
    let markup = TestMarkup()
    content(markup)
    #expect(markup.commands == [
        "beginDocument", "beginHeading:1", "text:ConcordUI", "endHeading",
        "beginParagraph", "text:Portable ", "beginStrong", "text:Swift",
        "endStrong", "endParagraph", "endDocument"
    ])
}

@Test("Unsupported special markup data is ignored")
func unsupportedSpecialMarkupDataIsIgnored() {
    #expect(TestMarkup().addSpecialData(type: "com.example.command", data: "{}") == false)
}

@Test("Markup style sheets encode and decode")
func markupStyleSheetsEncodeAndDecode() throws {
    let sheet = ConcordMarkupStyleSheet(rules: [
        ConcordMarkupStyleRule(
            selector: ConcordMarkupStyleSelector(.heading(level: 1), styleName: "title"),
            style: ConcordMarkupStyle(
                fontFamily: "System",
                fontSize: 28,
                fontWeight: .bold,
                foregroundColor: .black,
                textAlignment: .center,
                margins: ConcordMarkupEdges(bottom: 12)
            )
        )
    ])
    let data = try JSONEncoder().encode(sheet)
    #expect(try JSONDecoder().decode(ConcordMarkupStyleSheet.self, from: data) == sheet)
}
