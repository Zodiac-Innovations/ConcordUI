import Foundation

public extension ConcordMaterial {
    // MARK: Reserved framework keys

    static let requiredIndicatorKey = "concordui-required-indicator"
    static let invalidIndicatorKey = "concordui-invalid-indicator"
    static let fieldFrameKey = "concordui-field-frame"
    static let destructiveActionKey = "concordui-destructive-action"
    static let accessAccentKey = "concordui-access-accent"
    static let featureAccentKey = "concordui-feature-accent"
    static let buttonBackgroundKey = "concordui-button-background"
    static let buttonForegroundKey = "concordui-button-foreground"
    static let buttonFrameKey = "concordui-button-frame"
    static let rasterBackgroundKey = "concordui-raster-background"
    static let overlappingImagesBackgroundKey = "concordui-overlapping-images-background"
    static let workStackUpperBackgroundKey = "concordui-work-stack-upper-background"
    static let workStackLowerBackgroundKey = "concordui-work-stack-lower-background"

    static let requiredIndicator = ConcordMaterial.registered(requiredIndicatorKey)
    static let invalidIndicator = ConcordMaterial.registered(invalidIndicatorKey)
    static let fieldFrame = ConcordMaterial.registered(fieldFrameKey)
    static let destructiveAction = ConcordMaterial.registered(destructiveActionKey)
    static let accessAccent = ConcordMaterial.registered(accessAccentKey)
    static let featureAccent = ConcordMaterial.registered(featureAccentKey)
    static let buttonBackground = ConcordMaterial.registered(buttonBackgroundKey)
    static let buttonForeground = ConcordMaterial.registered(buttonForegroundKey)
    static let buttonFrame = ConcordMaterial.registered(buttonFrameKey)
    static let rasterBackground = ConcordMaterial.registered(rasterBackgroundKey)
    static let overlappingImagesBackground = ConcordMaterial.registered(overlappingImagesBackgroundKey)
    static let workStackUpperBackground = ConcordMaterial.registered(workStackUpperBackgroundKey)
    static let workStackLowerBackground = ConcordMaterial.registered(workStackLowerBackgroundKey)

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
    static func registerMaterials(
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


}
