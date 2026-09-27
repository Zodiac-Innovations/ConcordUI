//
//  ConcordMaterial.swift
//  ConcordUI
//
//  Platform-independent drawing materials and framework material defaults.
//

import Foundation

public enum ConcordMaterialType: Codable, Sendable, Equatable {
    case color(ConcordColor)
    case registered(key: String)
    case image(name: String)
}

public struct ConcordMaterial: Codable, Sendable, Equatable {
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

    // MARK: Reserved framework keys

    public static let requiredIndicatorKey = "concordui-required-indicator"
    public static let invalidIndicatorKey = "concordui-invalid-indicator"
    public static let fieldFrameKey = "concordui-field-frame"
    public static let destructiveActionKey = "concordui-destructive-action"
    public static let accessAccentKey = "concordui-access-accent"
    public static let featureAccentKey = "concordui-feature-accent"
    public static let buttonBackgroundKey = "concordui-button-background"
    public static let buttonForegroundKey = "concordui-button-foreground"
    public static let buttonFrameKey = "concordui-button-frame"
    public static let rasterBackgroundKey = "concordui-raster-background"
    public static let overlappingImagesBackgroundKey = "concordui-overlapping-images-background"
    public static let workStackUpperBackgroundKey = "concordui-work-stack-upper-background"
    public static let workStackLowerBackgroundKey = "concordui-work-stack-lower-background"

    public static let requiredIndicator = ConcordMaterial.registered(requiredIndicatorKey)
    public static let invalidIndicator = ConcordMaterial.registered(invalidIndicatorKey)
    public static let fieldFrame = ConcordMaterial.registered(fieldFrameKey)
    public static let destructiveAction = ConcordMaterial.registered(destructiveActionKey)
    public static let accessAccent = ConcordMaterial.registered(accessAccentKey)
    public static let featureAccent = ConcordMaterial.registered(featureAccentKey)
    public static let buttonBackground = ConcordMaterial.registered(buttonBackgroundKey)
    public static let buttonForeground = ConcordMaterial.registered(buttonForegroundKey)
    public static let buttonFrame = ConcordMaterial.registered(buttonFrameKey)
    public static let rasterBackground = ConcordMaterial.registered(rasterBackgroundKey)
    public static let overlappingImagesBackground = ConcordMaterial.registered(overlappingImagesBackgroundKey)
    public static let workStackUpperBackground = ConcordMaterial.registered(workStackUpperBackgroundKey)
    public static let workStackLowerBackground = ConcordMaterial.registered(workStackLowerBackgroundKey)

    internal static let reservedKeys: Set<String> = [
        requiredIndicatorKey,
        invalidIndicatorKey,
        fieldFrameKey,
        destructiveActionKey,
        accessAccentKey,
        featureAccentKey,
        buttonBackgroundKey,
        buttonForegroundKey,
        buttonFrameKey,
        rasterBackgroundKey,
        overlappingImagesBackgroundKey,
        workStackUpperBackgroundKey,
        workStackLowerBackgroundKey,
    ]

    /// Restores every ConcordUI default. Applications may override any predefined
    /// key by registering another terminal material after application creation.
    public static func registerMaterials(
        in registry: ConcordMaterialRegistry = .shared
    ) {
        registry.register(key: requiredIndicatorKey, material: .color(.red))
        registry.register(key: invalidIndicatorKey, material: .color(.error))
        registry.register(
            key: fieldFrameKey,
            material: .color(.rgba(0.5, 0.5, 0.5, 0.45))
        )
        registry.register(key: destructiveActionKey, material: .color(.error))
        registry.register(key: accessAccentKey, material: .color(.accent))
        registry.register(key: featureAccentKey, material: .color(.accent))
        registry.register(key: buttonBackgroundKey, material: .color(.accent))
        registry.register(key: buttonForegroundKey, material: .color(.white))
        registry.register(
            key: buttonFrameKey,
            material: .color(.rgba(0.5, 0.5, 0.5, 0.35))
        )
        registry.register(key: rasterBackgroundKey, material: .color(.white))
        registry.register(key: overlappingImagesBackgroundKey, material: .color(.white))
        registry.register(key: workStackUpperBackgroundKey, material: .color(.clear))
        registry.register(
            key: workStackLowerBackgroundKey,
            material: .color(.rgba(0.5, 0.5, 0.5, 0.14))
        )
    }

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

public final class ConcordMaterialRegistry: @unchecked Sendable {
    public static let shared = ConcordMaterialRegistry()

    private let lock = NSLock()
    private var materials: [String: ConcordMaterial] = [:]

    public init() {}

    public func register(key: String, material: ConcordMaterial) {
        precondition(
            !key.hasPrefix("concordui-") || ConcordMaterial.reservedKeys.contains(key),
            "Material keys beginning with 'concordui-' are reserved by ConcordUI."
        )
        lock.lock()
        materials[key] = material
        lock.unlock()
    }

    public func remove(key: String) {
        lock.lock()
        materials.removeValue(forKey: key)
        lock.unlock()
    }

    public func removeAll() {
        lock.lock()
        materials.removeAll()
        lock.unlock()
    }

    public func material(forKey key: String) -> ConcordMaterial? {
        lock.lock()
        defer { lock.unlock() }
        return materials[key]
    }

    public func resolve(_ material: ConcordMaterial) -> ConcordMaterial {
        guard case .registered(let key) = material.type else {
            return material
        }

        lock.lock()
        let registeredMaterial = materials[key]
        lock.unlock()

        guard let registeredMaterial else {
            return .black
        }
        if case .registered = registeredMaterial.type {
            return .black
        }
        return registeredMaterial
    }
}
