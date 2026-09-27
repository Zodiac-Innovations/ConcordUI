//
//  ConcordPresentation.swift
//  ConcordUI
//
//  Defines the portable ConcordUI presentation model.
//

import Foundation

open class ConcordPresentation {
    public let id: UUID
    public var tag: Int
    public var name: String

    /// Root element tree for the currently built Presentation UI.
    ///
    /// A lightweight placeholder exists while the Presentation is inactive. After
    /// `startPresentation()`, `buildElements()` replaces it with a fresh element tree.
    /// ConcordUI releases that transient tree after `finishPresentation()`.
    public private(set) var root: ConcordElement

    /// Builder stored by the Presentation and invoked only after the Presentation starts.
    private let elementBuilder: ConcordElementBuilder

    /// Feature-owned footer elements applied immediately after the deferred tree is built.
    private var pendingWorkStackBottomElements: [(element: ConcordElement, centered: Bool)] = []

    public var action: ConcordActionClosure?
    public var data: (any ConcordDataProtocol)?

    /// Optional display overrides for this Presentation.
    public var displayOptions: ConcordDisplayOptions?

    /// The Venue currently hosting this Presentation, or nil while it is inactive.
    ///
    /// A Presentation owns its functional UI and Elements; its Venue owns registration,
    /// display, lifecycle placement, and the native hosting context.
    public internal(set) weak var venue: ConcordVenue?

    /// Optional whole-presentation rule for relationships between elements.
    public var validation: (() -> Bool)?

    /// Becomes true after the Presentation has been explicitly validated.
    public private(set) var validationIsActive: Bool = false

    public init(
        id: UUID = UUID(), tag: Int = 0, name: String = "",
        data: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil,
        action: ConcordActionClosure? = nil,
        validation: (() -> Bool)? = nil,
        _ content: @escaping ConcordElementBuilder
    ) {
        self.id = id
        self.tag = tag
        self.name = name
        self.data = data
        self.displayOptions = displayOptions
        self.action = action
        self.validation = validation
        self.elementBuilder = content

        // Element construction is intentionally deferred until after startPresentation().
        self.root = ConcordVStack()
    }

    public convenience init(
        id: UUID = UUID(), tag: Int = 0, name: String = "",
        data: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil,
        action: ConcordActionClosure? = nil,
        validation: (() -> Bool)? = nil
    ) {
        self.init(
            id: id,
            tag: tag,
            name: name,
            data: data,
            displayOptions: displayOptions,
            action: action,
            validation: validation
        ) { ConcordVStack() }
    }

    // MARK: - Presentation Lifecycle

    /// Called before this Presentation's element tree is built and placed before the user.
    open func startPresentation() {}

    /// Called immediately before this Presentation disappears or is replaced.
    open func finishPresentation() {}

    /// Builds or rebuilds the Presentation's root element tree.
    internal func buildElements() {
        root = elementBuilder()
        for pending in pendingWorkStackBottomElements {
            appendElementToWorkStackBottom(
                pending.element,
                centered: pending.centered
            )
        }
        pendingWorkStackBottomElements.removeAll()
        cleanBlanks()
    }

    /// Schedules a feature-owned control for the Work Stack footer after the
    /// Presentation's deferred element tree has been built.
    internal func appendElementToWorkStackBottomAfterBuild(
        _ element: ConcordElement,
        centered: Bool = false
    ) {
        pendingWorkStackBottomElements.append((element, centered))
    }

    private func appendElementToWorkStackBottom(
        _ element: ConcordElement,
        centered: Bool
    ) {
        let workStack: ConcordWorkStack
        if let existing = root as? ConcordWorkStack {
            workStack = existing
        } else {
            workStack = ConcordWorkStack([root])
            root = workStack
        }
        workStack.bottom.add(element)
        if centered {
            workStack.bottom.centerJustified()
        }
    }

    /// Adds venue-owned chrome below the Presentation's content before dispatchers attach.
    internal func appendElementToBottom(_ element: ConcordElement) {
        if let stack = root as? ConcordVStack {
            stack.add(element)
        } else {
            root = ConcordVStack([root, element])
        }
    }

    /// Removes every blank placeholder from the Presentation's element tree.
    /// ConcordUI calls this automatically whenever the deferred tree is built.
    public func cleanBlanks() {
        if root is ConcordBlankElement {
            root = ConcordVStack()
            return
        }
        cleanBlanks(in: root)
    }

    private func cleanBlanks(in element: ConcordElement) {
        guard let container = element as? ConcordContainer else { return }
        container.elements.removeAll { $0 is ConcordBlankElement }
        for child in container.elements {
            cleanBlanks(in: child)
        }
    }

    /// Releases framework-owned transient UI state after `finishPresentation()`.
    internal func cleanupAfterFinish() {
        validationIsActive = false
        root = ConcordVStack()
    }

    // MARK: - Presentation Behavior

    open func handleAction(_ event: ConcordActionEvent) -> Bool { false }
    public func element(id: UUID) -> ConcordElement? { firstElement { $0.id == id } }
    public func element(name: String) -> ConcordElement? { firstElement { $0.name == name } }
    public func element(tag: Int) -> ConcordElement? { firstElement { $0.tag == tag } }
    public func element(position: Int) -> ConcordElement? { firstElement { $0.position == position } }

    /// Activates validation UI and asks every validatable child to validate itself.
    @discardableResult
    public func validate() -> Bool {
        validationIsActive = true
        var valid = true
        walkElements { element in
            if let validatable = element as? any ConcordValidatable, !validatable.validate() { valid = false }
        }
        if let validation, !validation() { valid = false }
        root.notifyPresentationChanged()
        return valid
    }

    /// Returns every validatable child to its quiet pre-validation state.
    public func resetValidation() {
        validationIsActive = false
        walkElements { element in (element as? any ConcordValidatable)?.resetValidation() }
        root.notifyPresentationChanged()
    }

    /// Revalidates only the changed element after validation has been activated.
    internal func elementDidChange(_ element: ConcordElement) {
        guard validationIsActive else { return }
        (element as? any ConcordValidatable)?.validate()
        _ = validation?()
    }

    /// Copies fully resolved display information downward. Element-level text
    /// modifiers remain optional overrides and are not replaced by these defaults.
    internal func applyDisplayInformation(_ information: ConcordDisplayInformation) {
        walkElements { element in
            element.requiredIndicator = information.requiredIndicator
            element.invalidIndicator = information.invalidIndicator
            element.concordTheme = information.theme

            if element is any ConcordFontable {
                element.concordElementFont = information.elementFont
                element.concordElementFontSize = information.elementFontSize
            }
        }
    }

    /// Compatibility helper retained while callers migrate to complete display information.
    internal func applyValidationPresentation(required: ConcordRequiredIndicator, invalid: ConcordInvalidIndicator) {
        walkElements { element in
            element.requiredIndicator = required
            element.invalidIndicator = invalid
        }
    }

    /// Compatibility helper retained while callers migrate to complete display information.
    internal func applyTheme(_ theme: ConcordTheme) {
        walkElements { $0.concordTheme = theme }
    }

    internal func attachDispatchers(actionDispatcher: any ConcordActionDispatching, changeDispatcher: any ConcordElementChangeDispatching) {
        walkElements { element in
            element.actionDispatcher = actionDispatcher
            element.changeDispatcher = changeDispatcher
        }
    }

    private func walkElements(_ visit: (ConcordElement) -> Void) {
        func walk(_ element: ConcordElement) {
            visit(element)
            if let container = element as? ConcordContainer { for child in container.elements { walk(child) } }
        }
        walk(root)
    }

    private func firstElement(matching predicate: (ConcordElement) -> Bool) -> ConcordElement? {
        var result: ConcordElement?
        walkElements { element in if result == nil && predicate(element) { result = element } }
        return result
    }
}
