import Testing
@testable import ConcordUI

private let overlappingTestImages: [ConcordImageData] = [
    .asset("one"),
    .asset("two"),
    .asset("three"),
    .asset("four"),
    .asset("five")
]

@Test("Stacked images put the first image in front")
func stackedImagesUseFrontFirstZOrder() {
    let element = ConcordOverlappingImagesElement(.stacked, images: overlappingTestImages)
    let commands = element.imageCommands(in: ConcordSize(width: 320, height: 220))

    #expect(commands.count == 5)
    #expect(commands.first?.zOrder == 5)
    #expect(commands.last?.zOrder == 1)
    #expect(commands[1].rect.origin.x < commands[0].rect.origin.x)
    #expect(commands[2].rect.origin.x > commands[0].rect.origin.x)
    #expect(commands[1].rect.size.width < commands[0].rect.size.width)
}

@Test("Top-left layout advances toward the bottom-right foreground")
func topLeftImagesAdvanceToRightFront() {
    let element = ConcordOverlappingImagesElement(.topLeftToBottomRight, images: overlappingTestImages)
    let commands = element.imageCommands(in: ConcordSize(width: 320, height: 220))

    #expect(commands.count == 5)
    #expect(commands.first?.zOrder == 0)
    #expect(commands.last?.zOrder == 4)
    #expect(commands.first!.rect.origin.x < commands.last!.rect.origin.x)
    #expect(commands.first!.rect.origin.y < commands.last!.rect.origin.y)
    #expect(commands.first!.rect.size.width < commands.last!.rect.size.width)
}

@Test("Overlapping image placement recalculates for view size")
func overlappingImagesRecalculateForSize() {
    let element = ConcordOverlappingImagesElement(.stacked, images: overlappingTestImages)
    let small = element.imageCommands(in: ConcordSize(width: 200, height: 100))
    let large = element.imageCommands(in: ConcordSize(width: 400, height: 200))

    #expect(large[0].rect.size.width == small[0].rect.size.width * 2)
    #expect(large[0].rect.size.height == small[0].rect.size.height * 2)
}

@Test("Overlapping image shrink percentage defaults to ten")
func overlappingImagesDefaultShrink() {
    let element = ConcordOverlappingImagesElement(.stacked, images: overlappingTestImages)

    #expect(element.shrinkPercentage == 10)
}


@Test("Directional image flavors use all four corner paths")
func directionalImageFlavorsUseFourCornerPaths() {
    let size = ConcordSize(width: 320, height: 220)
    let topRight = ConcordOverlappingImagesElement(.topRightToBottomLeft, images: overlappingTestImages)
        .imageCommands(in: size)
    let bottomLeft = ConcordOverlappingImagesElement(.bottomLeftToTopRight, images: overlappingTestImages)
        .imageCommands(in: size)
    let bottomRight = ConcordOverlappingImagesElement(.bottomRightToTopLeft, images: overlappingTestImages)
        .imageCommands(in: size)

    #expect(topRight.first!.rect.origin.x > topRight.last!.rect.origin.x)
    #expect(topRight.first!.rect.origin.y < topRight.last!.rect.origin.y)
    #expect(bottomLeft.first!.rect.origin.x < bottomLeft.last!.rect.origin.x)
    #expect(bottomLeft.first!.rect.origin.y > bottomLeft.last!.rect.origin.y)
    #expect(bottomRight.first!.rect.origin.x > bottomRight.last!.rect.origin.x)
    #expect(bottomRight.first!.rect.origin.y > bottomRight.last!.rect.origin.y)
}
