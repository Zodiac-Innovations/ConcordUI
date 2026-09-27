//
//  ConcordData.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/16/26.
//
//  Defines portable data passed through ConcordUI presentations.
//

import Foundation

/// Base protocol for data passed through ConcordUI presentations.
///
/// ConcordUI data may be either reference or value based. Mutable data typically uses
/// reference semantics and refines this contract with in-place filling, while read-only
/// data may use value semantics and adds stable identity, hashing, and concurrency safety.
public protocol ConcordDataProtocol: Codable {
    func clone() -> Self
}

/// Injected data that ConcordUI may update in place from another object of the same type.
public protocol ConcordMutableDataProtocol: ConcordDataProtocol {
    func fill(from other: Self)
}

/// Immutable injected data with stable identity that is safe to share across concurrency domains.
public protocol ConcordReadOnlyDataProtocol:
    ConcordDataProtocol,
    Identifiable,
    Hashable,
    Sendable
{}

/// Presentation-owned builder used to create the root element tree after the Presentation starts.
public typealias ConcordElementBuilder = () -> ConcordElement

// MARK: - Single-Value Mutable Data

nonisolated public final class ConcordStringData: ConcordMutableDataProtocol, CustomStringConvertible {
    public var value: String

    public init(_ value: String) {
        self.value = value
    }

    public var description: String { value }

    public func clone() -> Self {
        Self(value)
    }

    public func fill(from other: ConcordStringData) {
        value = other.value
    }
}

nonisolated public final class ConcordBoolData: ConcordMutableDataProtocol, CustomStringConvertible {
    public var value: Bool

    public init(_ value: Bool) {
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        Self(value)
    }

    public func fill(from other: ConcordBoolData) {
        value = other.value
    }
}

nonisolated public final class ConcordIntData: ConcordMutableDataProtocol, CustomStringConvertible {
    public var value: Int

    public init(_ value: Int) {
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        Self(value)
    }

    public func fill(from other: ConcordIntData) {
        value = other.value
    }
}

nonisolated public final class ConcordFloatData: ConcordMutableDataProtocol, CustomStringConvertible {
    public var value: Double

    public init(_ value: Double) {
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        Self(value)
    }

    public func fill(from other: ConcordFloatData) {
        value = other.value
    }
}

// MARK: - Single-Value Read-Only Data

nonisolated public struct ConcordStaticStringData: ConcordReadOnlyDataProtocol, CustomStringConvertible {
    public let id: UUID
    public let value: String

    public init(_ value: String, id: UUID = UUID()) {
        self.id = id
        self.value = value
    }

    public var description: String { value }

    public func clone() -> Self {
        self
    }
}

nonisolated public struct ConcordStaticBoolData: ConcordReadOnlyDataProtocol, CustomStringConvertible {
    public let id: UUID
    public let value: Bool

    public init(_ value: Bool, id: UUID = UUID()) {
        self.id = id
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        self
    }
}

nonisolated public struct ConcordStaticIntData: ConcordReadOnlyDataProtocol, CustomStringConvertible {
    public let id: UUID
    public let value: Int

    public init(_ value: Int, id: UUID = UUID()) {
        self.id = id
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        self
    }
}

nonisolated public struct ConcordStaticFloatData: ConcordReadOnlyDataProtocol, CustomStringConvertible {
    public let id: UUID
    public let value: Double

    public init(_ value: Double, id: UUID = UUID()) {
        self.id = id
        self.value = value
    }

    public var description: String { value.description }

    public func clone() -> Self {
        self
    }
}
