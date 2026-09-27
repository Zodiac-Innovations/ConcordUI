//
//  ConcordExpander.swift
//  ConcordUI
//
//  Expandable vertical container and simple horizontal line element.
//

import Foundation

/// Visual style used by `ConcordExpander` for its expand/collapse control.
public enum ConcordExpanderFlavor: Sendable, Equatable {
    /// A disclosure triangle/chevron changes direction with expansion state.
    case triangle

    /// A checkbox is checked while the contents are expanded.
    case checkbox
}

/// A simple horizontal rule used to visually separate content.
public final class ConcordLine: ConcordElement {}

/// A labeled container whose vertically arranged child elements can be shown or hidden.
public final class ConcordExpander: ConcordContainer {
    public let flavor: ConcordExpanderFlavor
    public var label: String

    /// `true` places the disclosure control after the label; `false` places it before the label.
    public var onRight: Bool

    /// Current expansion state.
    public private(set) var isExpanded: Bool

    /// Whether the disclosure label uses bold emphasis.
    public private(set) var labelIsBold: Bool

    public init(
        _ flavor: ConcordExpanderFlavor,
        label: String,
        elements: [ConcordElement] = [],
        expanded: Bool = false,
        onRight: Bool = true
    ) {
        self.flavor = flavor
        self.label = label
        self.onRight = onRight
        self.isExpanded = expanded
        self.labelIsBold = false
        super.init(elements)
    }

    @discardableResult
    public func expanded(_ expanded: Bool = true) -> Self {
        guard isExpanded != expanded else { return self }
        isExpanded = expanded
        notifyPresentationChanged()
        return self
    }

    @discardableResult
    public func bold(_ bold: Bool = true) -> Self {
        guard labelIsBold != bold else { return self }
        labelIsBold = bold
        notifyPresentationChanged()
        return self
    }

    @discardableResult
    public func controlOnRight(_ onRight: Bool = true) -> Self {
        guard self.onRight != onRight else { return self }
        self.onRight = onRight
        notifyPresentationChanged()
        return self
    }

    public func toggleExpanded() {
        isExpanded.toggle()
        notifyPresentationChanged()
    }
}
