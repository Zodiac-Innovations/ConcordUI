//
//  ConcordWorkStack.swift
//  ConcordUI
//
//  Standard two-region layout for app feature presentations.
//

import Foundation

/// Arranges main content and feature actions using native platform conventions.
///
/// Desktop renderers use a fixed-height, lightly shaded action area with a
/// right-justified horizontal row. Mobile renderers omit the shading and place
/// actions in a left-justified vertical list.
public final class ConcordWorkStack: ConcordContainer {
    public static let defaultBottomHeight: Double = 56

    public let main: ConcordVStack
    public let bottom: ConcordHStack
    public let bottomHeight: Double
    public var upperBackgroundMaterial: ConcordMaterial
    public var lowerBackgroundMaterial: ConcordMaterial

    public init(
        _ elements: [ConcordElement],
        bottom bottomElements: [ConcordElement] = []
    ) {
        self.main = ConcordVStack(elements)
        self.bottom = ConcordHStack(bottomElements).rightJustified()
        self.bottomHeight = Self.defaultBottomHeight
        self.upperBackgroundMaterial = .workStackUpperBackground
        self.lowerBackgroundMaterial = .workStackLowerBackground
        super.init([main, bottom])
        main.backgroundColor = ConcordMaterial.resolvedColor(upperBackgroundMaterial)
        bottom.backgroundColor = ConcordMaterial.resolvedColor(lowerBackgroundMaterial)
        edge = 0
        spacing = 0
    }
}
