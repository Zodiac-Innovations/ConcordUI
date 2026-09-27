//
//  ConcordABStack.swift
//  ConcordUI
//
//  Adaptive two-region stack.
//

import Foundation

/// Arranges two vertical regions side by side on desktop and in landscape,
/// or with region A above region B on mobile and pad devices in portrait.
public final class ConcordABStack: ConcordContainer {
    public let a: ConcordVStack
    public let b: ConcordVStack
    /// Fraction of horizontal content width assigned to A. Defaults to half.
    public let aFraction: Double

    public init(a: ConcordVStack, b: ConcordVStack, aFraction: Double = 0.5) {
        precondition(aFraction > 0 && aFraction < 1, "ABStack A fraction must be between 0 and 1.")
        self.a = a
        self.b = b
        self.aFraction = aFraction
        super.init([a, b])
    }
}
