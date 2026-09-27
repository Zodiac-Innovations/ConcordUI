//
//  ConcordSpacing.swift
//  ConcordUI
//
//  Portable spacing capability for layout containers.
//

/// A container whose spacing between child elements can be configured.
public protocol ConcordSpaced: AnyObject {
    var spacing: Double { get set }
}

public extension ConcordSpaced {
    @discardableResult
    func spacing(_ spacing: Double) -> Self {
        self.spacing = max(0, spacing)
        return self
    }
}

extension ConcordContainer: ConcordSpaced {}
