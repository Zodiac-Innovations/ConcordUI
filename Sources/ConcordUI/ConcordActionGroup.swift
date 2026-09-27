//
//  ConcordActionGroup.swift
//  ConcordUI
//
//  Cross-platform groups of application actions.
//

import Foundation

/// An ordered, titled collection of operations that can be presented as a
/// macOS menu or a popup element on other platforms.
public final class ConcordActionGroup {
    public static let specialTag = "concordui-special"

    public let tag: String
    public let title: String
    public private(set) var actions: [ConcordTitleAction] = []

    internal init(tag: String, title: String) {
        precondition(!tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "An action-group tag must not be empty.")
        precondition(!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "An action-group title must not be empty.")
        self.tag = tag
        self.title = title
    }

    internal func add(_ action: ConcordTitleAction) {
        actions.append(action)
    }
}

/// A popup control backed by an Action Group registered with its application.
public class ConcordActionGroupButton: ConcordElement {
    /// String identifier of the registered Action Group. This is distinct from
    /// ConcordElement.tag, which remains the element's integer lookup tag.
    public let groupTag: String
    public let title: String?
    public let image: ConcordImageData?

    public init(
        tag: String,
        title: String? = nil,
        image: ConcordImageData? = nil
    ) {
        precondition(!tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "An action-group button tag must not be empty.")
        self.groupTag = tag
        self.title = title
        self.image = image
        super.init()
    }

    /// Resolves the group after this element has been attached to a Presentation.
    public func resolvedActionGroup() -> ConcordActionGroup? {
        guard let venue = actionDispatcher as? ConcordVenue else { return nil }
        return venue.application?.actionGroup(tag: groupTag)
    }

    /// The caller's title override, or the registered Action Group title.
    public func resolvedTitle() -> String {
        if let title {
            return title
        }
        guard let group = resolvedActionGroup() else {
            return ""
        }
        return group.actions.count == 1
            ? group.actions[0].title
            : group.title
    }
}


public extension ConcordApplication {
    /// Creates a control containing every action in the predefined Special group.
    func concordAllSpecialButton(
        title: String? = nil,
        flavor: ConcordTitleActionFlavor = .popup,
        image: ConcordImageData? = nil
    ) -> ConcordElement {
        guard let group = actionGroup(tag: ConcordActionGroup.specialTag),
              !group.actions.isEmpty else {
            return ConcordBlankElement()
        }

        let resolvedTitle = title
            ?? (group.actions.count == 1 ? group.actions[0].title : group.title)
        return ConcordTitleActionElement(
            flavor,
            actions: group.actions,
            label: resolvedTitle,
            image: image
        )
        .edge(0)
    }
}
