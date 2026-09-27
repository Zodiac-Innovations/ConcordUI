//
//  ConcordButton.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/15/26.
//

import Foundation

/// Native button presentations supported across ConcordUI platforms.
public enum ConcordButtonFlavor: Sendable, Equatable {
    /// A native text-only button without a filled background.
    case text

    /// A native filled button with rounded rectangular edges.
    case roundedRectangle

    /// A native icon-only button using a standard semantic icon.
    case icon

    /// A native text button with its semantic icon displayed after the title.
    case textIcon
}

/// Semantic action roles that platforms present and invoke according to native conventions.
public enum ConcordButtonRole: Sendable, Equatable {
    case normal
    case defaultAction
    case cancel
    case destructive
}

/// A native button that emits a ConcordUI button-activation action.
public class ConcordButton: ConcordElement {
    public var flavor: ConcordButtonFlavor {
        didSet {
            guard oldValue != flavor else { return }
            notifyPresentationChanged()
        }
    }

    public var role: ConcordButtonRole {
        didSet {
            guard oldValue != role else { return }
            notifyPresentationChanged()
        }
    }

    public var title: String {
        didSet {
            guard oldValue != title else { return }
            notifyPresentationChanged()
        }
    }

    public var icon: ConcordStandardIcon? {
        didSet {
            guard oldValue != icon else { return }
            notifyPresentationChanged()
        }
    }

    /// Creates a button. Title-only buttons use the native rounded-rectangle style by default.
    public init(
        _ title: String,
        flavor: ConcordButtonFlavor = .roundedRectangle,
        icon: ConcordStandardIcon? = nil,
        action: ConcordActionClosure? = nil
    ) {
        self.flavor = flavor
        self.role = .normal
        self.title = title
        self.icon = icon
        super.init()
        if icon != nil {
            accessibilityText = title
        }
        if let action { onAction(.buttonActivate, action) }
    }

    /// Convenience initializer for the common case where event details are not needed.
    public convenience init(
        _ title: String,
        flavor: ConcordButtonFlavor = .roundedRectangle,
        icon: ConcordStandardIcon? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, flavor: flavor, icon: icon, action: { _ in action() })
    }

    /// Creates an icon-only button. The title is used as its accessibility label.
    public convenience init(
        icon: ConcordStandardIcon,
        accessibilityLabel: String,
        action: ConcordActionClosure? = nil
    ) {
        self.init(accessibilityLabel, flavor: .icon, icon: icon, action: action)
        self.accessibilityText = accessibilityLabel
    }

    /// Creates an icon-only button with an action that does not need event details.
    public convenience init(
        icon: ConcordStandardIcon,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.init(icon: icon, accessibilityLabel: accessibilityLabel, action: { _ in action() })
    }

    /// Marks this button as the presentation's default action.
    @discardableResult
    public func defaultAction() -> Self {
        role = .defaultAction
        return self
    }

    /// Marks this button as a cancel action.
    @discardableResult
    public func cancelAction() -> Self {
        role = .cancel
        return self
    }

    /// Marks this button as destructive.
    @discardableResult
    public func destructiveAction() -> Self {
        role = .destructive
        return self
    }

    public func activate() {
        guard isEnabled else { return }
        emitAction(.buttonActivate)
    }
}
