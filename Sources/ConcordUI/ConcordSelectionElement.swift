//
//  ConcordSelectionElement.swift
//  ConcordUI
//
//  Strongly typed single-selection elements with shared presentation flavors.
//

import Foundation

public enum ConcordSelectionFlavor: Sendable, Equatable {
    case popup
    case spinner
    case radio
    case segmented
    case list
}

public struct ConcordStringTaggedItem: Sendable, Equatable, Hashable {
    public var text: String
    public var tag: String
    public init(_ text: String, tag: String) { self.text = text; self.tag = tag }
}

public struct ConcordIntTaggedItem: Sendable, Equatable, Hashable {
    public var text: String
    public var tag: ConcordInt
    public init(_ text: String, tag: ConcordInt) { self.text = text; self.tag = tag }
}

/// Shared rendering contract for all single-selection elements.
public protocol ConcordSelectionPresenting: AnyObject {
    var flavor: ConcordSelectionFlavor { get }
    var label: String { get set }
    var itemCount: Int { get }
    var selectedIndex: Int? { get }
    func displayText(at index: Int) -> String
    func userSelected(index: Int)
}

/// Capability for tagged selections that can optionally display the semantic tag.
public protocol ConcordTagDisplayable: AnyObject {
    var showsTag: Bool { get set }
}

public extension ConcordTagDisplayable {
    @discardableResult func showTag(_ show: Bool = true) -> Self {
        showsTag = show
        return self
    }
}

public typealias ConcordStringSelectionChangeClosure = (_ index: Int?, _ text: String?) -> Void
public typealias ConcordIndexSelectionChangeClosure = (_ index: Int?, _ text: String?) -> Void
public typealias ConcordStringTaggedSelectionChangeClosure = (_ index: Int?, _ text: String?, _ tag: String?) -> Void
public typealias ConcordIntTaggedSelectionChangeClosure = (_ index: Int?, _ text: String?, _ tag: ConcordInt?) -> Void

// MARK: - String value

public final class ConcordStringSelectionElement: ConcordElement, ConcordValidatable, ConcordSelectionPresenting {
    public let flavor: ConcordSelectionFlavor
    public var label: String
    public var items: [String]
    public var onChange: ConcordStringSelectionChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: String?
    private var binding: ConcordBinding<String?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: String? {
        get { binding?.value ?? storedValue }
        set { writeValue(newValue); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [String], value: String? = nil) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = value; self.binding = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [String], value: ConcordBinding<String?>) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = nil; self.binding = value; self.onChange = nil
        super.init()
    }

    public var itemCount: Int { items.count }
    public var selectedIndex: Int? { value.flatMap { items.firstIndex(of: $0) } }
    public func displayText(at index: Int) -> String { items.indices.contains(index) ? items[index] : "" }

    @discardableResult public func onChange(_ closure: @escaping ConcordStringSelectionChangeClosure) -> Self { onChange = closure; return self }

    public func userSelected(index: Int) {
        guard isEnabled, !isReadOnly, items.indices.contains(index) else { return }
        let newValue = items[index]
        writeValue(newValue)
        onChange?(index, newValue)
        emitAction(.valueChanged)
        notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool { validateSelection(value != nil) }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func validateSelection(_ hasValue: Bool) -> Bool {
        clearValidationError()
        if isRequired && !hasValue { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ value: String?) { if let binding { binding.value = value } else { storedValue = value } }
}

// MARK: - Index value

public final class ConcordIndexSelectionElement: ConcordElement, ConcordValidatable, ConcordSelectionPresenting {
    public let flavor: ConcordSelectionFlavor
    public var label: String
    public var items: [String]
    public var onChange: ConcordIndexSelectionChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: ConcordInt?
    private var binding: ConcordBinding<ConcordInt?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: ConcordInt? {
        get { binding?.value ?? storedValue }
        set { writeValue(newValue); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [String], value: ConcordInt? = nil) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = value; self.binding = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [String], value: ConcordBinding<ConcordInt?>) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = nil; self.binding = value; self.onChange = nil
        super.init()
    }

    public var itemCount: Int { items.count }
    public var selectedIndex: Int? { guard let value, value >= 0, value < ConcordInt(items.count) else { return nil }; return Int(value) }
    public func displayText(at index: Int) -> String { items.indices.contains(index) ? items[index] : "" }

    @discardableResult public func onChange(_ closure: @escaping ConcordIndexSelectionChangeClosure) -> Self { onChange = closure; return self }

    public func userSelected(index: Int) {
        guard isEnabled, !isReadOnly, items.indices.contains(index) else { return }
        let newValue = ConcordInt(index)
        writeValue(newValue)
        onChange?(index, items[index])
        emitAction(.valueChanged)
        notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool { validateSelection(selectedIndex != nil) }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func validateSelection(_ hasValue: Bool) -> Bool {
        clearValidationError()
        if isRequired && !hasValue { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ value: ConcordInt?) { if let binding { binding.value = value } else { storedValue = value } }
}

// MARK: - String tag value

public final class ConcordStringTaggedSelectionElement: ConcordElement, ConcordValidatable, ConcordSelectionPresenting, ConcordTagDisplayable {
    public let flavor: ConcordSelectionFlavor
    public var label: String
    public var items: [ConcordStringTaggedItem]
    public var showsTag: Bool = false
    public var onChange: ConcordStringTaggedSelectionChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: String?
    private var binding: ConcordBinding<String?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: String? {
        get { binding?.value ?? storedValue }
        set { writeValue(newValue); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [ConcordStringTaggedItem], value: String? = nil) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = value; self.binding = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [ConcordStringTaggedItem], value: ConcordBinding<String?>) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = nil; self.binding = value; self.onChange = nil
        super.init()
    }

    public var itemCount: Int { items.count }
    public var selectedIndex: Int? { value.flatMap { tag in items.firstIndex { $0.tag == tag } } }
    public func displayText(at index: Int) -> String {
        guard items.indices.contains(index) else { return "" }
        let item = items[index]
        return showsTag ? "\(item.text) (\(item.tag))" : item.text
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordStringTaggedSelectionChangeClosure) -> Self { onChange = closure; return self }

    public func userSelected(index: Int) {
        guard isEnabled, !isReadOnly, items.indices.contains(index) else { return }
        let item = items[index]
        writeValue(item.tag)
        onChange?(index, item.text, item.tag)
        emitAction(.valueChanged)
        notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool { validateSelection(selectedIndex != nil) }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func validateSelection(_ hasValue: Bool) -> Bool {
        clearValidationError()
        if isRequired && !hasValue { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ value: String?) { if let binding { binding.value = value } else { storedValue = value } }
}

// MARK: - Integer tag value

public final class ConcordIntTaggedSelectionElement: ConcordElement, ConcordValidatable, ConcordSelectionPresenting, ConcordTagDisplayable {
    public let flavor: ConcordSelectionFlavor
    public var label: String
    public var items: [ConcordIntTaggedItem]
    public var showsTag: Bool = false
    public var onChange: ConcordIntTaggedSelectionChangeClosure?
    public private(set) var validationState: ConcordValidationState = .unvalidated

    private var storedValue: ConcordInt?
    private var binding: ConcordBinding<ConcordInt?>?
    private var validationGeneratedError: String?

    public var isBound: Bool { binding != nil }
    public var value: ConcordInt? {
        get { binding?.value ?? storedValue }
        set { writeValue(newValue); notifyPresentationChanged() }
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [ConcordIntTaggedItem], value: ConcordInt? = nil) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = value; self.binding = nil; self.onChange = nil
        super.init()
    }

    public init(_ flavor: ConcordSelectionFlavor, label: String = "", items: [ConcordIntTaggedItem], value: ConcordBinding<ConcordInt?>) {
        self.flavor = flavor; self.label = label; self.items = items; self.storedValue = nil; self.binding = value; self.onChange = nil
        super.init()
    }

    public var itemCount: Int { items.count }
    public var selectedIndex: Int? { value.flatMap { tag in items.firstIndex { $0.tag == tag } } }
    public func displayText(at index: Int) -> String {
        guard items.indices.contains(index) else { return "" }
        let item = items[index]
        return showsTag ? "\(item.text) (\(item.tag))" : item.text
    }

    @discardableResult public func onChange(_ closure: @escaping ConcordIntTaggedSelectionChangeClosure) -> Self { onChange = closure; return self }

    public func userSelected(index: Int) {
        guard isEnabled, !isReadOnly, items.indices.contains(index) else { return }
        let item = items[index]
        writeValue(item.tag)
        onChange?(index, item.text, item.tag)
        emitAction(.valueChanged)
        notifyPresentationChanged()
    }

    @discardableResult public func validate() -> Bool { validateSelection(selectedIndex != nil) }
    public func resetValidation() { clearValidationError(); validationState = .unvalidated; notifyPresentationChanged() }
    private func validateSelection(_ hasValue: Bool) -> Bool {
        clearValidationError()
        if isRequired && !hasValue { validationGeneratedError = ConcordString.required; errorText = ConcordString.required; validationState = .invalid; return false }
        validationState = .valid; return true
    }
    private func clearValidationError() { if let validationGeneratedError, errorText == validationGeneratedError { errorText = nil }; validationGeneratedError = nil }
    private func writeValue(_ value: ConcordInt?) { if let binding { binding.value = value } else { storedValue = value } }
}
