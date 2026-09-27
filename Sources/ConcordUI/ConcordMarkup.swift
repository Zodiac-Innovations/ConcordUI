//
//  ConcordMarkup.swift
//  ConcordUI
//
//  Platform-independent semantic markup definitions.
//

import Foundation

// MARK: - Style Values

public enum ConcordMarkupFontWeight: String, Codable, Sendable, Equatable {
    case light
    case regular
    case medium
    case semibold
    case bold
}

public enum ConcordMarkupTextAlignment: String, Codable, Sendable, Equatable {
    case leading
    case center
    case trailing
    case justified
}

/// Optional spacing around a markup block. Nil edges inherit from less-specific rules.
public struct ConcordMarkupEdges: Codable, Sendable, Equatable {
    public var top: ConcordFloat?
    public var leading: ConcordFloat?
    public var bottom: ConcordFloat?
    public var trailing: ConcordFloat?

    public init(
        top: ConcordFloat? = nil,
        leading: ConcordFloat? = nil,
        bottom: ConcordFloat? = nil,
        trailing: ConcordFloat? = nil
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

/// Typed visual properties applied by a markup style-sheet rule.
/// Nil properties inherit from the applicable less-specific style.
public struct ConcordMarkupStyle: Codable, Sendable, Equatable {
    public var fontFamily: String?
    public var fontSize: ConcordFloat?
    public var fontWeight: ConcordMarkupFontWeight?
    public var isItalic: Bool?
    public var isUnderlined: Bool?
    public var foregroundColor: ConcordColor?
    public var backgroundColor: ConcordColor?
    public var textAlignment: ConcordMarkupTextAlignment?
    public var lineSpacing: ConcordFloat?
    public var firstLineIndent: ConcordFloat?
    public var margins: ConcordMarkupEdges?
    public var padding: ConcordMarkupEdges?

    public init(
        fontFamily: String? = nil,
        fontSize: ConcordFloat? = nil,
        fontWeight: ConcordMarkupFontWeight? = nil,
        isItalic: Bool? = nil,
        isUnderlined: Bool? = nil,
        foregroundColor: ConcordColor? = nil,
        backgroundColor: ConcordColor? = nil,
        textAlignment: ConcordMarkupTextAlignment? = nil,
        lineSpacing: ConcordFloat? = nil,
        firstLineIndent: ConcordFloat? = nil,
        margins: ConcordMarkupEdges? = nil,
        padding: ConcordMarkupEdges? = nil
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.textAlignment = textAlignment
        self.lineSpacing = lineSpacing
        self.firstLineIndent = firstLineIndent
        self.margins = margins
        self.padding = padding
    }
}

// MARK: - Style Sheet

/// Semantic markup roles that may be selected by a style-sheet rule.
public enum ConcordMarkupRole: Codable, Sendable, Equatable {
    case document
    case section
    case heading(level: Int)
    case paragraph
    case text
    case strong
    case emphasis
    case link
    case orderedList
    case unorderedList
    case listItem
    case image
    case blockQuote
    case code
    case preformatted
    case horizontalRule
}

/// Selects a semantic role and, optionally, a developer-assigned style name.
public struct ConcordMarkupStyleSelector: Codable, Sendable, Equatable {
    public var role: ConcordMarkupRole
    public var styleName: String?

    public init(_ role: ConcordMarkupRole, styleName: String? = nil) {
        self.role = role
        self.styleName = styleName
    }
}

/// One ordered style-sheet rule. Later equally specific rules may override earlier rules.
public struct ConcordMarkupStyleRule: Codable, Sendable, Equatable {
    public var selector: ConcordMarkupStyleSelector
    public var style: ConcordMarkupStyle

    public init(selector: ConcordMarkupStyleSelector, style: ConcordMarkupStyle) {
        self.selector = selector
        self.style = style
    }
}

/// Typed, portable style rules used when laying out a markup recording.
public struct ConcordMarkupStyleSheet: Codable, Sendable, Equatable {
    public var rules: [ConcordMarkupStyleRule]

    public init(rules: [ConcordMarkupStyleRule] = []) {
        self.rules = rules
    }
}

// MARK: - Markup Behavior

public enum ConcordMarkupListKind: String, Codable, Sendable, Equatable {
    case ordered
    case unordered
}

/// Issues platform-independent semantic document commands.
/// Begin and end calls must be balanced and properly nested.
public protocol ConcordMarkupProtocol: AnyObject {
    func beginDocument(style: String?)
    func endDocument()

    func beginSection(style: String?)
    func endSection()
    func beginHeading(level: Int, style: String?)
    func endHeading()
    func beginParagraph(style: String?)
    func endParagraph()

    func addText(_ text: String, style: String?)
    func addLineBreak()
    func beginStrong(style: String?)
    func endStrong()
    func beginEmphasis(style: String?)
    func endEmphasis()
    func beginLink(destination: String, style: String?)
    func endLink()

    func beginList(kind: ConcordMarkupListKind, start: Int?, style: String?)
    func endList()
    func beginListItem(style: String?)
    func endListItem()

    func addImage(_ image: ConcordImageData, alternateText: String?, style: String?)
    func beginBlockQuote(style: String?)
    func endBlockQuote()
    func beginCode(language: String?, style: String?)
    func endCode()
    func beginPreformatted(style: String?)
    func endPreformatted()
    func addHorizontalRule(style: String?)

    /// Offers opaque developer-defined data to a specialized markup implementation.
    /// Returns true when the implementation recognizes and handles the command.
    @discardableResult
    func addSpecialData(type: String, data: String) -> Bool
}

/// Reusable markup code that can target a native renderer, exporter, or recorder.
public typealias ConcordMarkupClosure = (_ markup: any ConcordMarkupProtocol) -> Void

public extension ConcordMarkupProtocol {
    @discardableResult
    func addSpecialData(type: String, data: String) -> Bool {
        false
    }

    func document(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginDocument(style: style)
        content(self)
        endDocument()
    }

    func section(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginSection(style: style)
        content(self)
        endSection()
    }

    func heading(level: Int, style: String? = nil, _ content: ConcordMarkupClosure) {
        beginHeading(level: level, style: style)
        content(self)
        endHeading()
    }

    func heading(_ text: String, level: Int, style: String? = nil) {
        heading(level: level, style: style) { $0.addText(text, style: nil) }
    }

    func paragraph(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginParagraph(style: style)
        content(self)
        endParagraph()
    }

    func paragraph(_ text: String, style: String? = nil) {
        paragraph(style: style) { $0.addText(text, style: nil) }
    }

    func text(_ text: String, style: String? = nil) {
        addText(text, style: style)
    }

    func strong(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginStrong(style: style)
        content(self)
        endStrong()
    }

    func strong(_ text: String, style: String? = nil) {
        strong(style: style) { $0.addText(text, style: nil) }
    }

    func emphasis(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginEmphasis(style: style)
        content(self)
        endEmphasis()
    }

    func emphasis(_ text: String, style: String? = nil) {
        emphasis(style: style) { $0.addText(text, style: nil) }
    }

    func link(_ text: String, destination: String, style: String? = nil) {
        beginLink(destination: destination, style: style)
        addText(text, style: nil)
        endLink()
    }

    func orderedList(start: Int = 1, style: String? = nil, _ content: ConcordMarkupClosure) {
        beginList(kind: .ordered, start: start, style: style)
        content(self)
        endList()
    }

    func unorderedList(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginList(kind: .unordered, start: nil, style: style)
        content(self)
        endList()
    }

    func listItem(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginListItem(style: style)
        content(self)
        endListItem()
    }

    func listItem(_ text: String, style: String? = nil) {
        listItem(style: style) { $0.addText(text, style: nil) }
    }

    func blockQuote(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginBlockQuote(style: style)
        content(self)
        endBlockQuote()
    }

    func code(language: String? = nil, style: String? = nil, _ content: ConcordMarkupClosure) {
        beginCode(language: language, style: style)
        content(self)
        endCode()
    }

    func preformatted(style: String? = nil, _ content: ConcordMarkupClosure) {
        beginPreformatted(style: style)
        content(self)
        endPreformatted()
    }
}
