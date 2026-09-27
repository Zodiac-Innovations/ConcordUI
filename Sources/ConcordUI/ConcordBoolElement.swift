//
//  ConcordBoolElement.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/17/26.
//

import Foundation

public enum ConcordBoolFlavor: Sendable, Equatable { case toggle, checkbox, radio }
public typealias ConcordBoolChangeClosure = (_ oldValue: Bool?, _ newValue: Bool?) -> Void

public final class ConcordBoolElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordBoolFlavor
    public var label: String
    public var trueName: String
    public var falseName: String
    public var onChange: ConcordBoolChangeClosure?
    /// Explicit control placement. Nil preserves the platform renderer default.
    public private(set) var isControlOnRight: Bool?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: Bool?
    private var binding: ConcordBinding<Bool?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: Bool? {
        get { binding?.value ?? storedValue }
        set { writeValue(newValue); notifyPresentationChanged() }
    }

    // Preferred initializers: identity/flavor, label, and value only.
    public init(_ flavor: ConcordBoolFlavor, label: String = "", value: Bool? = nil) {
        self.flavor = flavor
        self.label = label
        self.trueName = ConcordString.trueText
        self.falseName = ConcordString.falseText
        self.onChange = nil
        self.isControlOnRight = nil
        self.storedValue = value
        self.binding = nil
        super.init()
    }

    public init(_ flavor: ConcordBoolFlavor, label: String = "", value: ConcordBinding<Bool?>) {
        self.flavor = flavor
        self.label = label
        self.trueName = ConcordString.trueText
        self.falseName = ConcordString.falseText
        self.onChange = nil
        self.isControlOnRight = nil
        self.storedValue = nil
        self.binding = value
        super.init()
    }

    // Compatibility initializers. New code should configure optional behavior with fluent modifiers.
    public init(_ flavor: ConcordBoolFlavor, label: String = "", value: Bool? = nil,
                trueName: String = ConcordString.trueText, falseName: String = ConcordString.falseText,
                onChange: ConcordBoolChangeClosure? = nil,
                id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
                isVisible: Bool = true, isEnabled: Bool = true) {
        self.flavor = flavor; self.label = label; self.trueName = trueName; self.falseName = falseName
        self.onChange = onChange; self.isControlOnRight = nil; self.storedValue = value; self.binding = nil
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
    }

    public init(_ flavor: ConcordBoolFlavor, label: String = "", value: ConcordBinding<Bool?>,
                trueName: String = ConcordString.trueText, falseName: String = ConcordString.falseText,
                onChange: ConcordBoolChangeClosure? = nil,
                id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
                isVisible: Bool = true, isEnabled: Bool = true) {
        self.flavor = flavor; self.label = label; self.trueName = trueName; self.falseName = falseName
        self.onChange = onChange; self.isControlOnRight = nil; self.storedValue = nil; self.binding = value
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
    }

    /// Places a toggle or checkbox control after its label when true.
    /// Radio groups retain their native multi-control layout.
    @discardableResult
    public func controlOnRight(_ value: Bool = true) -> Self {
        isControlOnRight = value
        notifyPresentationChanged()
        return self
    }

    @discardableResult
    public func onChange(_ closure: @escaping ConcordBoolChangeClosure) -> Self {
        onChange = closure
        return self
    }

    public var valueName: String? { guard let value else { return nil }; return value ? trueName : falseName }

    public func userChangedValue(to newValue: Bool) {
        guard isEnabled, !isReadOnly else { return }
        let oldValue = value
        writeValue(newValue)
        onChange?(oldValue, newValue)
        emitAction(.valueChanged)
        notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool {
        clearValidationError()
        if isRequired && value == nil {
            validationGeneratedError = ConcordString.required
            errorText = ConcordString.required
            validationState = .invalid
            return false
        }
        validationState = .valid
        return true
    }

    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ newValue: Bool?) { if let binding { binding.value = newValue } else { storedValue = newValue } }
}
