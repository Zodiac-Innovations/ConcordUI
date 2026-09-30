import Foundation
import Testing
@testable import ConcordUI

private final class PaintContractDrawer: ConcordVectorDrawingProtocol {
    let bounds = ConcordRect(x: 0, y: 0, width: 100, height: 100)
    var stroke: ConcordVectorStroke?
    var fill: ConcordVectorFill?
    var bitmapMaterial: ConcordMaterial?
    var specialMaterial: ConcordMaterial?

    func drawLine(from start: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) { self.stroke = stroke }
    func drawRectangle(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawRoundedRectangle(in rect: ConcordRect, cornerRadius: ConcordFloat, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawOval(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawArc(center: ConcordPoint, radius: ConcordFloat, startAngle: ConcordFloat, endAngle: ConcordFloat, direction: ConcordVectorArcDirection, stroke: ConcordVectorStroke) { self.stroke = stroke }
    func drawPolygon(points: [ConcordPoint], stroke: ConcordVectorStroke?, fill: ConcordVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawQuadraticBezier(from start: ConcordPoint, control: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) { self.stroke = stroke }
    func drawCubicBezier(from start: ConcordPoint, control1: ConcordPoint, control2: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke) { self.stroke = stroke }
    func drawBitmap(data: Data, sourceRect: ConcordRect?, destinationRect: ConcordRect, opacity: ConcordFloat) {}
    func drawBitmap(data: Data, sourceRect: ConcordRect?, destinationRect: ConcordRect, opacity: ConcordFloat, material: ConcordMaterial) -> Bool { bitmapMaterial = material; return true }
    func drawSpecialData(type: String, data: String, material: ConcordMaterial) -> Bool { specialMaterial = material; return true }
}

@Test("Material registration rejects references and retains the existing terminal value")
func paintRegistrationValidation() {
    let registry = ConcordMaterialRegistry()
    #expect(registry.register(key: "piece", color: .red))
    #expect(!registry.register(key: "piece", material: .registered("other")))
    #expect(registry.resolve(.registered("piece")) == .color(.red))
    #expect(!registry.register(key: " ", color: .blue))
    #expect(!registry.register(key: "piece", imageName: " "))
    #expect(registry.register(key: "piece", imageName: "rook.png"))
    #expect(registry.resolve(.registered("piece")) == .image("rook.png"))
    registry.remove(key: "piece")
    #expect(registry.material(forKey: "piece") == nil)
    #expect(registry.resolve(.registered("piece")) == .black)
}

@Test("Shared colors and all material forms preserve JSON round trips")
func paintSerializationRoundTrip() throws {
    let colors: [ConcordColor] = [.rgba(0.2, 0.4, 0.6, 0.8), .accent, .clear]
    for color in colors {
        #expect(try JSONDecoder().decode(ConcordColor.self, from: JSONEncoder().encode(color)) == color)
    }
    for material in [ConcordMaterial.color(.blue), .image("rook.png"), .registered("piece")] {
        #expect(try JSONDecoder().decode(ConcordMaterial.self, from: JSONEncoder().encode(material)) == material)
    }
    #expect(ConcordColor.rgba(-1, 2, 0.5, 3) == .rgba(red: 0, green: 1, blue: 0.5, alpha: 1))
}

@Test("Every geometry command forwards material and color paint")
func paintGeometryForwarding() {
    let concrete = PaintContractDrawer()
    let drawer: any ConcordVectorDrawingProtocol = concrete
    let p = ConcordPoint(x: 1, y: 2)
    let q = ConcordPoint(x: 3, y: 4)
    let r = concrete.bounds
    let material = ConcordMaterial.registered("piece")
    drawer.drawLine(from: p, to: q, material: material, thickness: 3)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.stroke?.thickness == 3)
    drawer.drawArc(center: p, radius: 5, startAngle: 0, endAngle: 90, direction: .clockwise, color: .blue)
    #expect(concrete.stroke?.material == .color(.blue))
    drawer.drawQuadraticBezier(from: p, control: q, to: p, material: material)
    #expect(concrete.stroke?.material == material)
    drawer.drawCubicBezier(from: p, control1: q, control2: p, to: q, color: .red)
    #expect(concrete.stroke?.material == .color(.red))
    drawer.drawRectangle(in: r, strokeMaterial: material, fillMaterial: .image("paper.png"), thickness: 2)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.fill == ConcordVectorFill(material: .image("paper.png")))
    drawer.drawRoundedRectangle(in: r, cornerRadius: 4, color: .green)
    #expect(concrete.stroke == nil)
    #expect(concrete.fill == ConcordVectorFill(color: .green))
    drawer.drawOval(in: r, material: material, filled: false)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.fill == nil)
    drawer.drawPolygon(points: [p, q, p], strokeColor: .red, fillColor: .blue)
    #expect(concrete.stroke?.material == .color(.red))
    #expect(concrete.fill == ConcordVectorFill(color: .blue))
}

@Test("Painted bitmap and special commands dispatch through the protocol")
func paintedSpecialDispatch() {
    let concrete = PaintContractDrawer()
    let drawer: any ConcordVectorDrawingProtocol = concrete
    #expect(drawer.drawBitmap(data: Data([1]), sourceRect: nil, destinationRect: concrete.bounds, opacity: 1, color: .blue))
    #expect(concrete.bitmapMaterial == .color(.blue))
    #expect(drawer.drawSpecialData(type: "example", data: "{}", material: .registered("piece")))
    #expect(concrete.specialMaterial == .registered("piece"))
}
