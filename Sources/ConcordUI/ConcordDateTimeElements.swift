//
//  ConcordDateTimeElements.swift
//  ConcordUI
//
//  Portable Date-backed date/time input elements.
//

import Foundation

/// Presentation flavor shared by Date-backed date, time, and date-time elements.
public enum ConcordDateFlavor: Sendable, Equatable {
    /// Localized value with the platform's native picker/editor.
    case picker
    /// Explicit localized component selectors/editors.
    case components
}

/// Semantic alias retained for time elements.
public typealias ConcordTimeFlavor = ConcordDateFlavor

/// Semantic alias retained for combined date-time elements.
public typealias ConcordDateTimeFlavor = ConcordDateFlavor

public typealias ConcordDateChangeClosure = (_ oldValue: Date?, _ newValue: Date?) -> Void

/// Shared capability for Date-backed ConcordUI elements that can constrain the allowed value.
public protocol ConcordDateRangeable: AnyObject {
    var minimumDate: Date? { get set }
    var maximumDate: Date? { get set }
}

public extension ConcordDateRangeable {
    /// Sets the optional lower and upper bounds as one semantic operation.
    @discardableResult
    func range(from minimum: Date? = nil, through maximum: Date? = nil) -> Self {
        minimumDate = minimum
        maximumDate = maximum
        return self
    }

    /// Sets a closed Date range.
    @discardableResult
    func range(_ range: ClosedRange<Date>) -> Self {
        minimumDate = range.lowerBound
        maximumDate = range.upperBound
        return self
    }
}

// MARK: - Date

public final class ConcordDateElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordDateFlavor
    public var label: String
    public var minimumDate: Date?
    public var maximumDate: Date?
    public var onChange: ConcordDateChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: Date?
    private var binding: ConcordBinding<Date?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: Date? {
        get { binding?.value ?? storedValue }
        set { writeValue(normalized(newValue)); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordDateFlavor = .picker, label: String = "", value: Date? = nil) {
        self.flavor = flavor; self.label = label; self.storedValue = value; self.binding = nil
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordDateFlavor = .picker, label: String = "", value: ConcordBinding<Date?>) {
        self.flavor = flavor; self.label = label; self.storedValue = nil; self.binding = value
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordDateChangeClosure) -> Self { onChange = closure; return self }
    public func userChangedValue(to newValue: Date?) { change(to: newValue) }
    @discardableResult public func validate() -> Bool { validateValue() }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }

    private func change(to newValue: Date?) {
        guard isEnabled, !isReadOnly else { return }
        let old = value; let adjusted = normalized(newValue); writeValue(adjusted)
        onChange?(old, adjusted); emitAction(.valueChanged); notifyPresentationChanged()
    }
    private func normalized(_ date: Date?) -> Date? {
        guard let date else { return nil }
        if let minimumDate, date < minimumDate { return minimumDate }
        if let maximumDate, date > maximumDate { return maximumDate }
        return date
    }
    private func writeValue(_ date: Date?) { if let binding { binding.value = date } else { storedValue = date } }
    private func validateValue() -> Bool {
        clearValidationError()
        if isRequired && value == nil { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
}

// MARK: - Time

public final class ConcordTimeElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordTimeFlavor
    public var label: String
    public var minimumDate: Date?
    public var maximumDate: Date?
    public var onChange: ConcordDateChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: Date?
    private var binding: ConcordBinding<Date?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: Date? {
        get { binding?.value ?? storedValue }
        set { writeValue(normalized(newValue)); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordTimeFlavor = .picker, label: String = "", value: Date? = nil) {
        self.flavor = flavor; self.label = label; self.storedValue = value; self.binding = nil
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordTimeFlavor = .picker, label: String = "", value: ConcordBinding<Date?>) {
        self.flavor = flavor; self.label = label; self.storedValue = nil; self.binding = value
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordDateChangeClosure) -> Self { onChange = closure; return self }
    public func userChangedValue(to newValue: Date?) { change(to: newValue) }
    @discardableResult public func validate() -> Bool { validateValue() }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }

    private func change(to newValue: Date?) {
        guard isEnabled, !isReadOnly else { return }
        let old = value; let adjusted = normalized(newValue); writeValue(adjusted)
        onChange?(old, adjusted); emitAction(.valueChanged); notifyPresentationChanged()
    }
    private func normalized(_ date: Date?) -> Date? {
        guard let date else { return nil }
        if let minimumDate, date < minimumDate { return minimumDate }
        if let maximumDate, date > maximumDate { return maximumDate }
        return date
    }
    private func writeValue(_ date: Date?) { if let binding { binding.value = date } else { storedValue = date } }
    private func validateValue() -> Bool {
        clearValidationError()
        if isRequired && value == nil { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
}

// MARK: - Date and Time

public final class ConcordDateTimeElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordDateTimeFlavor
    public var label: String
    public var minimumDate: Date?
    public var maximumDate: Date?
    public var onChange: ConcordDateChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: Date?
    private var binding: ConcordBinding<Date?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: Date? {
        get { binding?.value ?? storedValue }
        set { writeValue(normalized(newValue)); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordDateTimeFlavor = .picker, label: String = "", value: Date? = nil) {
        self.flavor = flavor; self.label = label; self.storedValue = value; self.binding = nil
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordDateTimeFlavor = .picker, label: String = "", value: ConcordBinding<Date?>) {
        self.flavor = flavor; self.label = label; self.storedValue = nil; self.binding = value
        self.minimumDate = nil; self.maximumDate = nil; self.onChange = nil
        super.init()
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordDateChangeClosure) -> Self { onChange = closure; return self }
    public func userChangedValue(to newValue: Date?) { change(to: newValue) }
    @discardableResult public func validate() -> Bool { validateValue() }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }

    private func change(to newValue: Date?) {
        guard isEnabled, !isReadOnly else { return }
        let old = value; let adjusted = normalized(newValue); writeValue(adjusted)
        onChange?(old, adjusted); emitAction(.valueChanged); notifyPresentationChanged()
    }
    private func normalized(_ date: Date?) -> Date? {
        guard let date else { return nil }
        if let minimumDate, date < minimumDate { return minimumDate }
        if let maximumDate, date > maximumDate { return maximumDate }
        return date
    }
    private func writeValue(_ date: Date?) { if let binding { binding.value = date } else { storedValue = date } }
    private func validateValue() -> Bool {
        clearValidationError()
        if isRequired && value == nil { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
}
