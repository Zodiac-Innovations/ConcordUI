import Foundation
import Testing
@testable import ConcordUI

private final class TestVectorDrawer: ConcordVectorDrawingProtocol {
    let bounds = ConcordRect(x: 0, y: 0, width: 100, height: 100)
    var line: (ConcordPoint, ConcordPoint, ConcordVectorStroke)?

    func drawLine(from start: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) {
        line = (start, end, stroke)
    }

    func drawRectangle(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) {}
    func drawRoundedRectangle(in rect: ConcordRect, cornerRadius: ConcordFloat, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) {}
    func drawOval(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) {}
    func drawArc(center: ConcordPoint, radius: ConcordFloat, startAngle: ConcordFloat, endAngle: ConcordFloat, direction: ConcordVectorArcDirection, stroke: ConcordVectorStroke) {}
    func drawPolygon(points: [ConcordPoint], stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) {}
    func drawQuadraticBezier(from start: ConcordPoint, control: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) {}
    func drawCubicBezier(from start: ConcordPoint, control1: ConcordPoint, control2: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) {}
    func drawBitmap(data: Data, sourceRect: ConcordRect?, destinationRect: ConcordRect, opacity: ConcordFloat) {}
}

@Test("Vector drawing closure targets protocol implementation")
func vectorDrawingClosureTargetsProtocolImplementation() {
    let drawing: ConcordVectorDrawingClosure = { drawer in
        drawer.drawLine(
            from: ConcordPoint(x: 1, y: 2),
            to: ConcordPoint(x: 3, y: 4),
            stroke: ConcordVectorStroke(color: .blue, thickness: 2)
        )
    }
    let drawer = TestVectorDrawer()

    drawing(drawer)

    #expect(drawer.line?.0 == ConcordPoint(x: 1, y: 2))
    #expect(drawer.line?.1 == ConcordPoint(x: 3, y: 4))
    #expect(drawer.line?.2.thickness == 2)
}

@Test("Unsupported special vector data is ignored")
func unsupportedSpecialVectorDataIsIgnored() {
    let drawer = TestVectorDrawer()
    #expect(drawer.drawSpecialData(type: "com.example.command", data: "{}") == false)
}

@Test("Vector values encode and decode")
func vectorValuesEncodeAndDecode() throws {
    let stroke = ConcordVectorStroke(
        color: .blue,
        thickness: 3,
        pattern: .dashed(lengths: [4, 2], phase: 1),
        cap: .round,
        join: .bevel
    )
    let data = try JSONEncoder().encode(stroke)
    #expect(try JSONDecoder().decode(ConcordVectorStroke.self, from: data) == stroke)
}
