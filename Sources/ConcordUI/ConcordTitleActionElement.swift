//
//  ConcordTitleActionElement.swift
//  ConcordUI
//
//  Titled actions presented as buttons or a popup menu.
//

import Foundation

/// A titled operation that can be presented by ConcordUI controls.
public struct ConcordTitleAction {
    public let title: String
    public let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        precondition(!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Action title must not be empty.")
        self.title = title
        self.action = action
    }

    public func invoke() {
        action()
    }
}

/// Layouts supported by a collection of titled actions.
public enum ConcordTitleActionFlavor: Sendable, Equatable {
    /// Places one action button per row.
    case vlist

    /// Places the action buttons in a horizontal row.
    case stack

    /// Presents the actions in a native popup menu.
    case popup
}

/// Presents titled closures as a vertical list, horizontal stack, or native popup.
public final class ConcordTitleActionElement: ConcordContainer {
    public let flavor: ConcordTitleActionFlavor
    public let actions: [ConcordTitleAction]
    public let label: String?
    public let image: ConcordImageData?

    public init(
        _ flavor: ConcordTitleActionFlavor,
        actions: [ConcordTitleAction],
        label: String? = nil,
        image: ConcordImageData? = nil
    ) {
        precondition(!actions.isEmpty, "A title-action element requires at least one action.")
        if flavor == .popup {
            let hasLabel = label.map {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            } ?? false
            precondition(hasLabel || image != nil,
                         "A popup title-action element requires a label or image.")
        }

        self.flavor = flavor
        self.actions = actions
        self.label = label
        self.image = image
        super.init(
            actions.map { item in
                ConcordButton(item.title) {
                    item.invoke()
                }
            }
        )
        accessibilityText = label
    }

    public var actionCount: Int {
        actions.count
    }

    public func actionTitle(at index: Int) -> String? {
        guard actions.indices.contains(index) else { return nil }
        return actions[index].title
    }

    public func activateAction(at index: Int) {
        guard isEnabled, actions.indices.contains(index) else { return }
        actions[index].invoke()
    }
}
