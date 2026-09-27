//
//  ConcordDisplayInformation.swift
//  ConcordUI
//
//  Defines resolved display information and optional per-Venue/Presentation overrides.
//

import Foundation

/// Complete display information supplied to ConcordUI rendering code.
public struct ConcordDisplayInformation: Sendable, Equatable {
    public let theme: ConcordTheme
    public let requiredIndicator: ConcordRequiredIndicator
    public let invalidIndicator: ConcordInvalidIndicator
    public let elementFont: ConcordFont
    public let elementFontSize: Double

    public init(
        theme: ConcordTheme,
        requiredIndicator: ConcordRequiredIndicator,
        invalidIndicator: ConcordInvalidIndicator,
        elementFont: ConcordFont = .system,
        elementFontSize: Double = 17
    ) {
        self.theme = theme
        self.requiredIndicator = requiredIndicator
        self.invalidIndicator = invalidIndicator
        self.elementFont = elementFont
        self.elementFontSize = elementFontSize
    }

    /// Returns a complete structure with non-nil options applied over this one.
    public func applying(_ options: ConcordDisplayOptions) -> ConcordDisplayInformation {
        ConcordDisplayInformation(
            theme: options.theme ?? theme,
            requiredIndicator: options.requiredIndicator ?? requiredIndicator,
            invalidIndicator: options.invalidIndicator ?? invalidIndicator,
            elementFont: options.elementFont ?? elementFont,
            elementFontSize: options.elementFontSize ?? elementFontSize
        )
    }
}

/// Partial display overrides supplied by a Venue or Presentation.
public struct ConcordDisplayOptions: Sendable, Equatable {
    public var theme: ConcordTheme?
    public var requiredIndicator: ConcordRequiredIndicator?
    public var invalidIndicator: ConcordInvalidIndicator?
    public var elementFont: ConcordFont?
    public var elementFontSize: Double?

    public init(
        theme: ConcordTheme? = nil,
        requiredIndicator: ConcordRequiredIndicator? = nil,
        invalidIndicator: ConcordInvalidIndicator? = nil,
        elementFont: ConcordFont? = nil,
        elementFontSize: Double? = nil
    ) {
        self.theme = theme
        self.requiredIndicator = requiredIndicator
        self.invalidIndicator = invalidIndicator
        self.elementFont = elementFont
        self.elementFontSize = elementFontSize
    }
}

/// ConcordUI-reserved Presentation tags. Developer-defined registration tags
/// must be positive; zero is invalid and negative values belong to ConcordUI.
internal enum ConcordSystemPresentationTag {
    static let home = -1
}
