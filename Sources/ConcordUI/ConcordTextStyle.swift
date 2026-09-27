//
//  ConcordTextStyle.swift
//  ConcordUICore
//
//  Created by Steve Sheets on 8/16/26.
//
//  Defines optional text traits shared by text-presenting ConcordUI elements.
//

import Foundation

// MARK: - Text Style

/// Optional text presentation traits applied by ConcordUI dot-notation modifiers.
public struct ConcordTextStyle: Sendable, Equatable {

    /// Whether the text is presented with bold emphasis.
    public var isBold: Bool

    /// Whether the text is presented with italic emphasis.
    public var isItalic: Bool

    /// Whether the text is underlined.
    public var isUnderlined: Bool

    /// Creates text style rules.
    public init(
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false
    ) {
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
    }
}
