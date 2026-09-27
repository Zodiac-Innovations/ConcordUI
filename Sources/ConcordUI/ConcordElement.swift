//
//  ConcordElement.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/15/26.
//
//  Defines the common base class for portable ConcordUI elements.
//

import Foundation

public enum ConcordHorizontalJustification: Sendable, Equatable { case left, center, right }

/// Abstract font families understood across ConcordUI platforms.
public enum ConcordFont: Sendable, Equatable {
    case system
    case monospaced
}

/// Simple portable border presentation for an element.
public struct ConcordBoxStyle: Sendable, Equatable {
    public var width: Double
    public var cornerRadius: Double
    public var padding: Double
    public init(width: Double = 1, cornerRadius: Double = 0, padding: Double = 4) {
        self.width = width; self.cornerRadius = cornerRadius; self.padding = padding
    }
}

/// Base identity and storage shared by all ConcordUI elements.
///
/// Public modifier behavior is intentionally supplied by capability protocols
/// such as `ConcordBoxable`, `ConcordSizable`, and `ConcordRequired` rather than
/// by this base class. Classes define what an element is; protocols define what
/// an element can do.
open class ConcordElement {
    public let id: UUID
    public var name: String
    public var tag: Int
    public var position: Int?
    public var isVisible: Bool
    public var isEnabled: Bool

    /// Low-level native rendering hints keyed by platform and hint number.
    public private(set) var platformHints: [ConcordPlatformHint]

    // Capability storage. Concrete element types opt into the corresponding
    // protocol(s); keeping storage here avoids duplicating state in every class.
    public var helpText: String?
    public var errorText: String?
    public var isRequired: Bool
    public var isReadOnly: Bool
    public var accessibilityText: String?
    public var debugString: String?
    public var requiredIndicator: ConcordRequiredIndicator
    public var invalidIndicator: ConcordInvalidIndicator
    public var font: ConcordFont? {
        didSet {
            guard oldValue != font else { return }
            notifyPresentationChanged()
        }
    }
    public var fontSize: Double? {
        didSet {
            guard oldValue != fontSize else { return }
            notifyPresentationChanged()
        }
    }

    /// Registry-resolved defaults used only when the element has no explicit font override.
    internal var concordElementFont: ConcordFont
    internal var concordElementFontSize: Double

    public var resolvedFont: ConcordFont { font ?? concordElementFont }
    public var resolvedFontSize: Double { fontSize ?? concordElementFontSize }

    /// Per-element color overrides. Nil means inherit from the active application theme.
    public var foregroundColor: ConcordColor? { didSet { if oldValue != foregroundColor { notifyPresentationChanged() } } }
    public var backgroundColor: ConcordColor? { didSet { if oldValue != backgroundColor { notifyPresentationChanged() } } }
    public var frameColor: ConcordColor? { didSet { if oldValue != frameColor { notifyPresentationChanged() } } }
    public var textColor: ConcordColor? { didSet { if oldValue != textColor { notifyPresentationChanged() } } }

    /// Theme copied downward by ConcordApplication when a Presentation is displayed.
    internal var concordTheme: ConcordTheme

    /// Effective presentation colors after element overrides are combined with the application theme.
    public var resolvedForegroundColor: ConcordColor? { foregroundColor ?? concordTheme.foregroundColor }
    public var resolvedBackgroundColor: ConcordColor? { backgroundColor ?? concordTheme.backgroundColor }
    public var resolvedFrameColor: ConcordColor? { frameColor ?? concordTheme.frameColor }
    public var resolvedTextColor: ConcordColor? { textColor ?? concordTheme.textColor ?? resolvedForegroundColor }

    public var horizontalJustification: ConcordHorizontalJustification?
    public var structure: ConcordElementStructure?
    public var boxStyle: ConcordBoxStyle?

    private var actionClosures: [ConcordActionType: ConcordActionClosure]
    internal weak var actionDispatcher: (any ConcordActionDispatching)?
    internal weak var changeDispatcher: (any ConcordElementChangeDispatching)?

    public init(
        id: UUID = UUID(),
        name: String = "",
        tag: Int = 0,
        position: Int? = nil,
        isVisible: Bool = true,
        isEnabled: Bool = true,
        horizontalJustification: ConcordHorizontalJustification? = nil
    ) {
        self.id = id
        self.name = name
        self.tag = tag
        self.position = position
        self.isVisible = isVisible
        self.isEnabled = isEnabled
        self.platformHints = []
        self.helpText = nil
        self.errorText = nil
        self.isRequired = false
        self.isReadOnly = false
        self.accessibilityText = nil
        self.debugString = nil
        self.requiredIndicator = .redAsterisk
        self.invalidIndicator = .errorText
        self.font = nil
        self.fontSize = nil
        self.concordElementFont = .system
        self.concordElementFontSize = 17
        self.foregroundColor = nil
        self.backgroundColor = nil
        self.frameColor = nil
        self.textColor = nil
        self.concordTheme = .system
        self.horizontalJustification = horizontalJustification
        self.structure = nil
        self.boxStyle = nil
        self.actionClosures = [:]
    }

    /// Adds or replaces a low-level hint for one platform.
    ///
    /// Concrete element types may override this method to validate, translate,
    /// or reject hint numbers that have element-specific meaning. Overrides that
    /// retain the standard storage behavior should call `super`.
    @discardableResult
    open func hint(
        platform: ConcordPlatformType,
        number: Int,
        param: Int? = nil
    ) -> Self {
        let hint = ConcordPlatformHint(platform: platform, number: number, param: param)
        if let index = platformHints.firstIndex(where: {
            $0.platform == platform && $0.number == number
        }) {
            platformHints[index] = hint
        } else {
            platformHints.append(hint)
        }
        notifyPresentationChanged()
        return self
    }

    /// Returns the hint matching a platform and element-specific hint number.
    public func hint(
        for platform: ConcordPlatformType,
        number: Int
    ) -> ConcordPlatformHint? {
        platformHints.first { $0.platform == platform && $0.number == number }
    }

    @discardableResult
    public func onAction(
        _ type: ConcordActionType,
        _ action: @escaping ConcordActionClosure
    ) -> Self {
        actionClosures[type] = action
        return self
    }

    @discardableResult
    public func removeAction(_ type: ConcordActionType) -> Self {
        actionClosures.removeValue(forKey: type)
        return self
    }

    internal func emitAction(_ type: ConcordActionType) {
        let event = ConcordActionEvent(type: type, element: self)
        if let action = actionClosures[type] {
            action(event)
            return
        }
        actionDispatcher?.dispatchAction(event)
    }

    internal func notifyPresentationChanged() {
        changeDispatcher?.elementDidChange(self)
    }
}
