//
//  ConcordBinding.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/17/26.
//
//  Defines the platform-independent value binding used by editable elements.
//

/// A lightweight two-way binding between a ConcordUI element and application data.
///
/// ConcordBinding is intentionally independent of SwiftUI.Binding so the same
/// ConcordUI application model can be used by every supported platform.
public struct ConcordBinding<Value> {

    private let getter: () -> Value
    private let setter: (Value) -> Void

    /// Creates a binding from value getter and setter closures.
    public init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void
    ) {
        self.getter = get
        self.setter = set
    }

    /// Current value of the binding.
    public var value: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }
}
