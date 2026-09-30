//
//  ConcordMaterial.swift
//  Concord
//
//  Shared portable material contract. Substitute only the project prefix.
//

import Foundation

public enum ConcordMaterialType: Codable, Sendable, Hashable {
    case color(ConcordColor)
    case registered(key: String)
    case image(name: String)
}

public struct ConcordMaterial: Codable, Sendable, Hashable {
    public var type: ConcordMaterialType

    public init(type: ConcordMaterialType) {
        self.type = type
    }

    public static func color(_ color: ConcordColor) -> ConcordMaterial {
        ConcordMaterial(type: .color(color))
    }

    public static func registered(_ key: String) -> ConcordMaterial {
        ConcordMaterial(type: .registered(key: key))
    }

    public static func image(_ name: String) -> ConcordMaterial {
        ConcordMaterial(type: .image(name: name))
    }

    public static let black = ConcordMaterial.color(.black)

    public static func resolvedColor(
        _ material: ConcordMaterial,
        in registry: ConcordMaterialRegistry = .shared
    ) -> ConcordColor {
        let resolved = registry.resolve(material)
        guard case .color(let color) = resolved.type else {
            return .black
        }
        return color
    }
}


/// Thread-safe registry of terminal color or image materials.
/// A registered key is a reference and cannot itself be registered as a value.
public final class ConcordMaterialRegistry: @unchecked Sendable {
    public static let shared = ConcordMaterialRegistry()

    private let lock = NSLock()
    private var materials: [String: ConcordMaterial] = [:]

    public init() {}

    /// Registers or replaces a terminal material. Invalid input returns false
    /// and leaves any existing value unchanged.
    @discardableResult
    public func register(key: String, material: ConcordMaterial) -> Bool {
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        switch material.type {
        case .registered: return false
        case .image(let name):
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        case .color: break
        }
        lock.lock()
        defer { lock.unlock() }
        materials[key] = material
        return true
    }

    @discardableResult
    public func register(key: String, color: ConcordColor) -> Bool {
        register(key: key, material: .color(color))
    }

    @discardableResult
    public func register(key: String, imageName: String) -> Bool {
        register(key: key, material: .image(imageName))
    }

    public func remove(key: String) {
        lock.lock()
        defer { lock.unlock() }
        materials.removeValue(forKey: key)
    }

    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        materials.removeAll()
    }

    public func material(forKey key: String) -> ConcordMaterial? {
        lock.lock()
        defer { lock.unlock() }
        return materials[key]
    }

    /// Resolves a key to its terminal value. Unknown keys use opaque black.
    public func resolve(_ material: ConcordMaterial) -> ConcordMaterial {
        guard case .registered(let key) = material.type else { return material }
        return self.material(forKey: key) ?? .black
    }
}
