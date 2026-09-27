import Foundation
import Testing
@testable import ConcordUI

@Test("Direct materials resolve unchanged")
func directMaterialsResolveUnchanged() {
    let registry = ConcordMaterialRegistry()
    #expect(registry.resolve(.color(.red)) == .color(.red))
    #expect(registry.resolve(.image("paper.png")) == .image("paper.png"))
}

@Test("Registered materials resolve colors and images")
func registeredMaterialsResolveTerminalValues() {
    let registry = ConcordMaterialRegistry()
    registry.register(key: "accent", material: .color(.blue))
    registry.register(key: "texture", material: .image("wood.png"))

    #expect(registry.resolve(.registered("accent")) == .color(.blue))
    #expect(registry.resolve(.registered("texture")) == .image("wood.png"))
}

@Test("Missing and nested registered materials resolve black")
func invalidRegisteredMaterialsResolveBlack() {
    let registry = ConcordMaterialRegistry()
    registry.register(key: "nested", material: .registered("accent"))
    registry.register(key: "accent", material: .color(.blue))

    #expect(registry.resolve(.registered("missing")) == .black)
    #expect(registry.resolve(.registered("nested")) == .black)
}

@Test("Material values encode and decode")
func materialValuesEncodeAndDecode() throws {
    let materials: [ConcordMaterial] = [
        .color(.green),
        .registered("primary"),
        .image("fabric.png"),
    ]

    for material in materials {
        let data = try JSONEncoder().encode(material)
        #expect(try JSONDecoder().decode(ConcordMaterial.self, from: data) == material)
    }
}

@Test("Framework materials register defaults and allow overrides")
func frameworkMaterialsRegisterDefaultsAndAllowOverrides() {
    let registry = ConcordMaterialRegistry()
    ConcordMaterial.registerMaterials(in: registry)

    #expect(
        registry.resolve(.workStackUpperBackground)
            == .color(.clear)
    )
    #expect(
        registry.resolve(.workStackLowerBackground)
            == .color(.rgba(0.5, 0.5, 0.5, 0.14))
    )

    registry.register(
        key: ConcordMaterial.workStackLowerBackgroundKey,
        material: .image("footer.png")
    )
    #expect(
        registry.resolve(.workStackLowerBackground)
            == .image("footer.png")
    )
}
