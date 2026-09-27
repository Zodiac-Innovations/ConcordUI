//
//  ConcordTextElement.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/17/26.
//

import Foundation

public enum ConcordTextFlavor: Sendable, Equatable { case normal, password }
public typealias ConcordTextChangeClosure = (_ oldValue: String?, _ newValue: String?) -> Void

public final class ConcordTextElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordTextFlavor
    public var label: String
    public var placeholder: String?
    public var regex: String?
    public var regexErrorMessage: String?
    public var onChange: ConcordTextChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated
    private var storedValue: String?
    private var binding: ConcordBinding<String?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: String? { get { binding?.value ?? storedValue } set { writeValue(newValue); notifyPresentationChanged() } }

    /// Non-optional text-content view used by shared text presentation capabilities.
    public var text: String {
        get { value ?? "" }
        set { value = newValue }
    }

    // Preferred initializers: flavor, label, and value only.
    public init(_ flavor: ConcordTextFlavor = .normal, label: String = "", value: String? = nil) {
        self.flavor = flavor; self.label = label; self.placeholder = nil; self.regex = nil
        self.regexErrorMessage = nil; self.onChange = nil; self.storedValue = value; self.binding = nil
        super.init()
    }

    public init(_ flavor: ConcordTextFlavor = .normal, label: String = "", value: ConcordBinding<String?>) {
        self.flavor = flavor; self.label = label; self.placeholder = nil; self.regex = nil
        self.regexErrorMessage = nil; self.onChange = nil; self.storedValue = nil; self.binding = value
        super.init()
    }

    // Compatibility initializers for existing source. Prefer fluent modifiers in new code.
    public init(_ flavor: ConcordTextFlavor = .normal, label: String = "", value: String? = nil,
                placeholder: String? = nil, error: String? = nil, regex: String? = nil,
                regexErrorMessage: String? = nil, onChange: ConcordTextChangeClosure? = nil,
                id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
                isVisible: Bool = true, isEnabled: Bool = true) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder; self.regex = regex
        self.regexErrorMessage = regexErrorMessage; self.onChange = onChange; self.storedValue = value; self.binding = nil
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled); self.errorText = error
    }

    public init(_ flavor: ConcordTextFlavor = .normal, label: String = "", value: ConcordBinding<String?>,
                placeholder: String? = nil, error: String? = nil, regex: String? = nil,
                regexErrorMessage: String? = nil, onChange: ConcordTextChangeClosure? = nil,
                id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
                isVisible: Bool = true, isEnabled: Bool = true) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder; self.regex = regex
        self.regexErrorMessage = regexErrorMessage; self.onChange = onChange; self.storedValue = nil; self.binding = value
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled); self.errorText = error
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordTextChangeClosure) -> Self { onChange = closure; return self }

    public func userChangedValue(to newValue: String?) {
        guard isEnabled, !isReadOnly else { return }
        let oldValue = value; writeValue(newValue); onChange?(oldValue, newValue); emitAction(.valueChanged); notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool {
        clearValidationError(); let candidate = value ?? ""
        if isRequired && candidate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return failValidation(ConcordString.required) }
        if candidate.isEmpty { validationState = .valid; return true }
        if let regex, !regex.isEmpty {
            let range = NSRange(candidate.startIndex..<candidate.endIndex, in: candidate)
            let matches: Bool
            do { matches = try NSRegularExpression(pattern: regex).firstMatch(in: candidate, range: range) != nil } catch { matches = false }
            if !matches {
                let configured = regexErrorMessage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return failValidation(configured.isEmpty ? ConcordString.invalidText : configured)
            }
        }
        validationState = .valid; return true
    }

    @discardableResult public func validateCurrentValue() -> Bool { validate() }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func failValidation(_ message: String) -> Bool { validationGeneratedError = message; errorText = message; validationState = .invalid; return false }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ newValue: String?) { if let binding { binding.value = newValue } else { storedValue = newValue } }
}
