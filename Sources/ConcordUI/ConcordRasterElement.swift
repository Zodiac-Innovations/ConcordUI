//
//  ConcordRasterElement.swift
//  ConcordUI
//
//  A portable raster composition surface using logical coordinates.
//

import Foundation

/// One image placement in a ``ConcordRasterElement``.
public struct ConcordRasterImageCommand: Sendable, Equatable {
    public let imageData: ConcordImageData
    public let rect: ConcordRect
    public let zOrder: Int
    public let contentMode: ConcordVectorContentMode
    internal let insertionOrder: Int

    internal init(
        imageData: ConcordImageData,
        rect: ConcordRect,
        zOrder: Int,
        contentMode: ConcordVectorContentMode,
        insertionOrder: Int
    ) {
        self.imageData = imageData
        self.rect = rect
        self.zOrder = zOrder
        self.contentMode = contentMode
        self.insertionOrder = insertionOrder
    }
}

/// Displays images positioned in a scalable local coordinate system.
///
/// The initializer's width and height define both the logical coordinate space
/// and the element's natural displayed size. Sizing modifiers may change the
/// displayed size; image rectangles are scaled automatically by each platform.
open class ConcordRasterElement: ConcordElement {
    public let coordinateSize: ConcordSize
    public private(set) var imageCommands: [ConcordRasterImageCommand]

    public init(
        width: ConcordFloat,
        height: ConcordFloat,
        backgroundColor: ConcordColor = ConcordMaterial.resolvedColor(.rasterBackground)
    ) {
        precondition(width > 0, "Raster width must be greater than zero")
        precondition(height > 0, "Raster height must be greater than zero")

        self.coordinateSize = ConcordSize(width: width, height: height)
        self.imageCommands = []
        super.init()
        self.backgroundColor = backgroundColor
        self.structure = ConcordElementStructure(
            width: .fixed(Double(width)),
            height: .fixed(Double(height))
        )
    }

    /// Adds an image at a rectangle expressed in the element's local coordinates.
    ///
    /// Lower Z orders are drawn first. Commands sharing a Z order retain the
    /// order in which they were added.
    @discardableResult
    open func drawImage(
        _ imageData: ConcordImageData,
        in rect: ConcordRect,
        zOrder: Int = 0,
        contentMode: ConcordVectorContentMode = .fit
    ) -> Self {
        guard rect.size.width > 0, rect.size.height > 0 else { return self }

        imageCommands.append(
            ConcordRasterImageCommand(
                imageData: imageData,
                rect: rect,
                zOrder: zOrder,
                contentMode: contentMode,
                insertionOrder: imageCommands.count
            )
        )
        imageCommands.sort {
            if $0.zOrder == $1.zOrder {
                return $0.insertionOrder < $1.insertionOrder
            }
            return $0.zOrder < $1.zOrder
        }
        notifyPresentationChanged()
        return self
    }

    /// Resolves image placement for a displayed size.
    ///
    /// The base implementation scales manually supplied local-coordinate
    /// commands. Specialized raster elements may override this to recalculate
    /// an adaptive layout whenever the displayed size changes.
    open func imageCommands(in displayedSize: ConcordSize) -> [ConcordRasterImageCommand] {
        guard displayedSize.width > 0, displayedSize.height > 0 else { return [] }
        return scaleImageCommands(imageCommands, to: displayedSize)
    }

    /// Uniformly scales commands into a displayed area while preserving their
    /// coordinate-space aspect ratio and centering unused space.
    internal func scaleImageCommands(
        _ commands: [ConcordRasterImageCommand],
        to displayedSize: ConcordSize
    ) -> [ConcordRasterImageCommand] {
        let scale = min(
            displayedSize.width / coordinateSize.width,
            displayedSize.height / coordinateSize.height
        )
        let offsetX = (displayedSize.width - coordinateSize.width * scale) / 2
        let offsetY = (displayedSize.height - coordinateSize.height * scale) / 2

        return commands.map { command in
            let rect = command.rect
            return ConcordRasterImageCommand(
                imageData: command.imageData,
                rect: ConcordRect(
                    x: offsetX + rect.origin.x * scale,
                    y: offsetY + rect.origin.y * scale,
                    width: rect.size.width * scale,
                    height: rect.size.height * scale
                ),
                zOrder: command.zOrder,
                contentMode: command.contentMode,
                insertionOrder: command.insertionOrder
            )
        }
    }

    /// Removes every image command from the surface.
    @discardableResult
    open func clearImages() -> Self {
        guard !imageCommands.isEmpty else { return self }
        imageCommands.removeAll()
        notifyPresentationChanged()
        return self
    }
}
