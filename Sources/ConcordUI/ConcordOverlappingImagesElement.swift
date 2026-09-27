//
//  ConcordOverlappingImagesElement.swift
//  ConcordUI
//
//  Adaptive overlapping image layouts built on ConcordRasterElement.
//

import Foundation

public enum ConcordOverlappingImagesFlavor: Sendable, Equatable {
    /// The first image is centered in front. Remaining images alternate left
    /// and right behind it, becoming smaller with depth.
    case stacked

    case topLeftToBottomRight
    case topRightToBottomLeft
    case bottomLeftToTopRight
    case bottomRightToTopLeft
}

/// Arranges a collection of images as an adaptive overlapping composition.
public final class ConcordOverlappingImagesElement: ConcordRasterElement {
    public let flavor: ConcordOverlappingImagesFlavor
    public let images: [ConcordImageData]
    public let shrinkPercentage: ConcordFloat

    private var cachedSize: ConcordSize?
    private var cachedCommands: [ConcordRasterImageCommand] = []

    public init(
        _ flavor: ConcordOverlappingImagesFlavor,
        images: [ConcordImageData],
        width: ConcordFloat = 320,
        height: ConcordFloat = 220,
        shrinkPercentage: ConcordFloat = 10,
        backgroundColor: ConcordColor = ConcordMaterial.resolvedColor(.overlappingImagesBackground)
    ) {
        self.flavor = flavor
        self.images = images
        self.shrinkPercentage = min(max(shrinkPercentage, 0), 99)
        super.init(width: width, height: height, backgroundColor: backgroundColor)
    }

    public override func imageCommands(in displayedSize: ConcordSize) -> [ConcordRasterImageCommand] {
        guard displayedSize.width > 0, displayedSize.height > 0, !images.isEmpty else {
            return []
        }
        if cachedSize == displayedSize {
            return cachedCommands
        }

        let logicalCommands: [ConcordRasterImageCommand]
        switch flavor {
        case .stacked:
            logicalCommands = stackedCommands(in: coordinateSize)
        case .topLeftToBottomRight,
             .topRightToBottomLeft,
             .bottomLeftToTopRight,
             .bottomRightToTopLeft:
            logicalCommands = directionalCommands(in: coordinateSize)
        }
        let commands = scaleImageCommands(logicalCommands, to: displayedSize)

        cachedSize = displayedSize
        cachedCommands = commands
        return commands
    }

    private var shrinkFactor: ConcordFloat {
        1 - shrinkPercentage / 100
    }

    private func stackedCommands(in size: ConcordSize) -> [ConcordRasterImageCommand] {
        let baseWidth = size.width * 0.44
        let baseHeight = size.height * 0.64
        let centerY = size.height / 2
        let lastSlot = max(images.count - 1, 1)
        let spacing = (size.width - baseWidth) / ConcordFloat(lastSlot)
        let centerSlot = ConcordFloat(images.count - 1) / 2

        return images.enumerated().map { index, image in
            let depth = ConcordFloat(index)
            let scale = pow(shrinkFactor, depth)
            let width = baseWidth * scale
            let height = baseHeight * scale
            let distance = ConcordFloat((index + 1) / 2)
            let slot = index == 0
                ? centerSlot
                : centerSlot + (index % 2 == 1 ? -distance : distance)
            let centerX = baseWidth / 2 + slot * spacing

            return command(
                image,
                x: centerX - width / 2,
                y: centerY - height / 2,
                width: width,
                height: height,
                zOrder: images.count - index,
                insertionOrder: index
            )
        }
    }

    private func directionalCommands(in size: ConcordSize) -> [ConcordRasterImageCommand] {
        let baseWidth = size.width * 0.46
        let baseHeight = size.height * 0.66
        let lastIndex = max(images.count - 1, 0)

        return images.enumerated().map { index, image in
            let depthFromFront = ConcordFloat(lastIndex - index)
            let scale = pow(shrinkFactor, depthFromFront)
            let width = baseWidth * scale
            let height = baseHeight * scale
            let progress = lastIndex == 0 ? 1 : ConcordFloat(index) / ConcordFloat(lastIndex)
            let horizontalProgress: ConcordFloat
            let verticalProgress: ConcordFloat

            switch flavor {
            case .topLeftToBottomRight:
                horizontalProgress = progress
                verticalProgress = progress
            case .topRightToBottomLeft:
                horizontalProgress = 1 - progress
                verticalProgress = progress
            case .bottomLeftToTopRight:
                horizontalProgress = progress
                verticalProgress = 1 - progress
            case .bottomRightToTopLeft:
                horizontalProgress = 1 - progress
                verticalProgress = 1 - progress
            case .stacked:
                horizontalProgress = progress
                verticalProgress = progress
            }

            return command(
                image,
                x: (size.width - width) * horizontalProgress,
                y: (size.height - height) * verticalProgress,
                width: width,
                height: height,
                zOrder: index,
                insertionOrder: index
            )
        }
    }

    private func command(
        _ image: ConcordImageData,
        x: ConcordFloat,
        y: ConcordFloat,
        width: ConcordFloat,
        height: ConcordFloat,
        zOrder: Int,
        insertionOrder: Int
    ) -> ConcordRasterImageCommand {
        ConcordRasterImageCommand(
            imageData: image,
            rect: ConcordRect(x: x, y: y, width: width, height: height),
            zOrder: zOrder,
            contentMode: .fit,
            insertionOrder: insertionOrder
        )
    }
}
