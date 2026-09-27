import Testing
@testable import ConcordUI

@Test("Raster element uses logical size and white background")
func rasterElementDefaults() {
    let raster = ConcordRasterElement(width: 320, height: 180)

    #expect(raster.coordinateSize == ConcordSize(width: 320, height: 180))
    #expect(raster.backgroundColor == .white)
    #expect(raster.structure?.width == .fixed(320))
    #expect(raster.structure?.height == .fixed(180))
}

@Test("Raster image commands are stable within Z order")
func rasterImageCommandsUseStableZOrder() {
    let raster = ConcordRasterElement(width: 100, height: 100)
        .drawImage(.asset("middle"), in: ConcordRect(x: 0, y: 0, width: 10, height: 10), zOrder: 2)
        .drawImage(.asset("back"), in: ConcordRect(x: 0, y: 0, width: 10, height: 10), zOrder: 1)
        .drawImage(.asset("front"), in: ConcordRect(x: 0, y: 0, width: 10, height: 10), zOrder: 2)

    #expect(raster.imageCommands.map(\.zOrder) == [1, 2, 2])
    #expect(raster.imageCommands.map(\.imageData) == [.asset("back"), .asset("middle"), .asset("front")])
}

@Test("Raster element ignores empty image rectangles")
func rasterElementIgnoresEmptyRectangles() {
    let raster = ConcordRasterElement(width: 100, height: 100)
        .drawImage(.asset("unused"), in: ConcordRect(x: 0, y: 0, width: 0, height: 10))

    #expect(raster.imageCommands.isEmpty)
}
