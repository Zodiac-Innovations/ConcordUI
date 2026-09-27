//
//  ConcordText.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/15/26.
//
//  Defines the portable ConcordUI static label element.
//

import Foundation

// MARK: - Label

/// Displays static text using the native presentation selected by the platform.
public final class ConcordLabel: ConcordElement {

    /// Text displayed by the label.
    public var text: String {
        didSet {
            guard oldValue != text else { return }
            notifyPresentationChanged()
        }
    }

    /// Optional semantic label shown before the value text using localized platform presentation.
    public var label: String?

    /// Optional text presentation overrides created by text-style modifiers.
    public var textStyle: ConcordTextStyle?

    /// Creates a static text label. Optional semantics and presentation are configured fluently.
    public init(_ text: String) {
        self.text = text
        self.label = nil
        self.textStyle = nil
        super.init()
    }

    /// Compatibility initializer retained while callers migrate to fluent configuration.
    public convenience init(
        _ text: String,
        label: String? = nil,
        id: UUID = UUID(),
        name: String = "",
        tag: Int = 0,
        position: Int? = nil,
        isVisible: Bool = true
    ) {
        self.init(text)
        self.label = label
        self.name = name
        self.tag = tag
        self.position = position
        self.isVisible = isVisible
    }

    @discardableResult public func bold() -> Self { ensureTextStyle(); textStyle?.isBold = true; return self }
    @discardableResult public func italic() -> Self { ensureTextStyle(); textStyle?.isItalic = true; return self }
    @discardableResult public func underline() -> Self { ensureTextStyle(); textStyle?.isUnderlined = true; return self }

    private func ensureTextStyle() {
        if textStyle == nil { textStyle = ConcordTextStyle() }
    }
}

// MARK: - Compatibility

public typealias ConcordText = ConcordLabel
