//
//  ConcordElementStructure.swift
//  ConcordUICore
//
//  Created by Steve Sheets on 8/16/26.
//
//  Defines optional portable sizing rules for ConcordUI elements.
//

import Foundation

// MARK: - Size Rule

/// Describes how one dimension of an element is sized.
public enum ConcordSizeRule: Sendable, Equatable {

    /// Uses the element's natural content size.
    case content

    /// Uses an explicit size in platform-independent layout units.
    case fixed(Double)

    /// Expands to use the space offered by the parent container.
    case fill
}

// MARK: - Element Structure

/// Optional layout structure created only when an element overrides default sizing behavior.
public struct ConcordElementStructure: Sendable, Equatable {

    /// Horizontal sizing rule, when explicitly overridden.
    public var width: ConcordSizeRule?

    /// Vertical sizing rule, when explicitly overridden.
    public var height: ConcordSizeRule?

    /// Creates element structure rules.
    public init(
        width: ConcordSizeRule? = nil,
        height: ConcordSizeRule? = nil
    ) {
        self.width = width
        self.height = height
    }
}
