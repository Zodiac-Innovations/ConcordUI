//
//  ConcordValidation.swift
//  ConcordUI
//
//  Defines portable validation state and the contract used by validatable elements.
//

/// Current validation result stored by an individual validatable element.
public enum ConcordValidationState: Sendable, Equatable {
    /// The owning Presentation has not yet asked this element to validate.
    case unvalidated

    /// The current value passed validation.
    case valid

    /// The current value failed validation.
    case invalid
}

/// Contract implemented by elements that participate in Presentation validation.
///
/// Elements validate only their own data. They do not know about their containing
/// Presentation, Section, or Application.
public protocol ConcordValidatable: AnyObject {
    var validationState: ConcordValidationState { get }

    /// Validates the element's current value and updates `validationState` and
    /// any validation-generated error text.
    @discardableResult
    func validate() -> Bool

    /// Returns the element to its quiet pre-validation presentation state.
    func resetValidation()
}

public extension ConcordValidatable {
    /// True only after validation has run and the element passed.
    var isValid: Bool {
        validationState == .valid
    }

    /// True only after validation has run and the element failed.
    var isInvalid: Bool {
        validationState == .invalid
    }

    /// True until the owning Presentation first requests validation (or after reset).
    var isUnvalidated: Bool {
        validationState == .unvalidated
    }
}
