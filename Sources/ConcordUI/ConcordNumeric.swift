//
//  ConcordNumeric.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/17/26.
//

import Foundation

public typealias ConcordInt = Int64
public typealias ConcordFloat = Double

public enum ConcordNumericFlavor: Sendable, Equatable {
    case input
    case stepper
    case slider
    case combo
}

public typealias ConcordIntChangeClosure = (_ oldValue: ConcordInt?, _ newValue: ConcordInt?) -> Void

public final class ConcordIntElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordNumericFlavor
    public var label: String
    public var placeholder: String?
    public var range: ClosedRange<ConcordInt>?
    public var step: ConcordInt
    public var onChange: ConcordIntChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: ConcordInt?
    private var binding: ConcordBinding<ConcordInt?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }

    public var value: ConcordInt? {
        get { binding?.value ?? storedValue }
        set { writeValue(normalized(newValue)); notifyPresentationChanged() }
    }

    // Preferred initializers: flavor, label, and value only.
    public init(_ flavor: ConcordNumericFlavor = .input, label: String = "", value: ConcordInt? = nil) {
        self.flavor = flavor
        self.label = label
        self.placeholder = nil
        self.range = nil
        self.step = 1
        self.onChange = nil
        self.storedValue = value
        self.binding = nil
        super.init()
    }

    public init(_ flavor: ConcordNumericFlavor = .input, label: String = "", value: ConcordBinding<ConcordInt?>) {
        self.flavor = flavor
        self.label = label
        self.placeholder = nil
        self.range = nil
        self.step = 1
        self.onChange = nil
        self.storedValue = nil
        self.binding = value
        super.init()
    }

    // Compatibility initializer for existing source. Prefer fluent modifiers in new code.
    public init(
        _ flavor: ConcordNumericFlavor = .input,
        label: String = "", value: ConcordInt? = nil, placeholder: String?,
        range: ClosedRange<ConcordInt>? = nil, step: ConcordInt = 1,
        onChange: ConcordIntChangeClosure? = nil,
        id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
        isVisible: Bool = true, isEnabled: Bool = true
    ) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder
        self.range = range; self.step = max(1, step); self.onChange = onChange
        self.storedValue = value; self.binding = nil
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
        self.storedValue = normalized(value)
    }

    public init(
        _ flavor: ConcordNumericFlavor = .input,
        label: String = "", value: ConcordBinding<ConcordInt?>, placeholder: String?,
        range: ClosedRange<ConcordInt>? = nil, step: ConcordInt = 1,
        onChange: ConcordIntChangeClosure? = nil,
        id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
        isVisible: Bool = true, isEnabled: Bool = true
    ) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder
        self.range = range; self.step = max(1, step); self.onChange = onChange
        self.storedValue = nil; self.binding = value
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
    }

    public var effectiveRange: ClosedRange<ConcordInt> { range ?? 0...100 }

    public func concordNormalizedStep(_ value: ConcordInt) -> ConcordInt { max(1, value) }

    @discardableResult
    public func onChange(_ closure: @escaping ConcordIntChangeClosure) -> Self {
        onChange = closure
        return self
    }

    public func userChangedValue(to newValue: ConcordInt?) {
        guard isEnabled, !isReadOnly else { return }
        let oldValue = value
        let adjusted = normalized(newValue)
        writeValue(adjusted)
        onChange?(oldValue, adjusted)
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

    public func resetValidation() {
        clearValidationError(); validationState = .unvalidated; notifyPresentationChanged()
    }

    private func clearValidationError() {
        if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }
        validationGeneratedError = nil
    }

    private func normalized(_ newValue: ConcordInt?) -> ConcordInt? {
        guard let newValue, let range else { return newValue }
        return min(max(newValue, range.lowerBound), range.upperBound)
    }

    private func writeValue(_ newValue: ConcordInt?) {
        if let binding { binding.value = newValue } else { storedValue = newValue }
    }
}

public typealias ConcordFloatChangeClosure = (_ oldValue: ConcordFloat?, _ newValue: ConcordFloat?) -> Void

public final class ConcordFloatElement: ConcordElement, ConcordValidatable {
    public let flavor: ConcordNumericFlavor
    public var label: String
    public var placeholder: String?
    public var range: ClosedRange<ConcordFloat>?
    public var step: ConcordFloat
    public var onChange: ConcordFloatChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: ConcordFloat?
    private var binding: ConcordBinding<ConcordFloat?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }

    public var value: ConcordFloat? {
        get { binding?.value ?? storedValue }
        set { writeValue(normalized(newValue)); notifyPresentationChanged() }
    }

    // Preferred initializers: flavor, label, and value only.
    public init(_ flavor: ConcordNumericFlavor = .input, label: String = "", value: ConcordFloat? = nil) {
        self.flavor = flavor
        self.label = label
        self.placeholder = nil
        self.range = nil
        self.step = 1.0
        self.onChange = nil
        self.storedValue = value
        self.binding = nil
        super.init()
    }

    public init(_ flavor: ConcordNumericFlavor = .input, label: String = "", value: ConcordBinding<ConcordFloat?>) {
        self.flavor = flavor
        self.label = label
        self.placeholder = nil
        self.range = nil
        self.step = 1.0
        self.onChange = nil
        self.storedValue = nil
        self.binding = value
        super.init()
    }

    // Compatibility initializer for existing source. Prefer fluent modifiers in new code.
    public init(
        _ flavor: ConcordNumericFlavor = .input,
        label: String = "", value: ConcordFloat? = nil, placeholder: String?,
        range: ClosedRange<ConcordFloat>? = nil, step: ConcordFloat = 1.0,
        onChange: ConcordFloatChangeClosure? = nil,
        id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
        isVisible: Bool = true, isEnabled: Bool = true
    ) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder
        self.range = range; self.step = step > 0 ? step : 1.0; self.onChange = onChange
        self.storedValue = value; self.binding = nil
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
        self.storedValue = normalized(value)
    }

    public init(
        _ flavor: ConcordNumericFlavor = .input,
        label: String = "", value: ConcordBinding<ConcordFloat?>, placeholder: String?,
        range: ClosedRange<ConcordFloat>? = nil, step: ConcordFloat = 1.0,
        onChange: ConcordFloatChangeClosure? = nil,
        id: UUID = UUID(), name: String = "", tag: Int = 0, position: Int? = nil,
        isVisible: Bool = true, isEnabled: Bool = true
    ) {
        self.flavor = flavor; self.label = label; self.placeholder = placeholder
        self.range = range; self.step = step > 0 ? step : 1.0; self.onChange = onChange
        self.storedValue = nil; self.binding = value
        super.init(id: id, name: name, tag: tag, position: position, isVisible: isVisible, isEnabled: isEnabled)
    }

    public var effectiveRange: ClosedRange<ConcordFloat> { range ?? 0.0...100.0 }

    public func concordNormalizedStep(_ value: ConcordFloat) -> ConcordFloat { value > 0 ? value : 1.0 }

    @discardableResult
    public func onChange(_ closure: @escaping ConcordFloatChangeClosure) -> Self {
        onChange = closure
        return self
    }

    public func userChangedValue(to newValue: ConcordFloat?) {
        guard isEnabled, !isReadOnly else { return }
        let oldValue = value
        let adjusted = normalized(newValue)
        writeValue(adjusted)
        onChange?(oldValue, adjusted)
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

    public func resetValidation() {
        clearValidationError(); validationState = .unvalidated; notifyPresentationChanged()
    }

    private func clearValidationError() {
        if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }
        validationGeneratedError = nil
    }

    private func normalized(_ newValue: ConcordFloat?) -> ConcordFloat? {
        guard let newValue, let range else { return newValue }
        return min(max(newValue, range.lowerBound), range.upperBound)
    }

    private func writeValue(_ newValue: ConcordFloat?) {
        if let binding { binding.value = newValue } else { storedValue = newValue }
    }
}
