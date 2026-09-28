import Testing
@testable import AndroidGenerator

@Test
func bridgeAndRendererTemplatesRemainComplete() {
    let bridge = AndroidVenueTemplate.swiftBridge(
        applicationType: "WowApplication", packageName: "com.example.wow"
    )
    #expect(bridge.contains("ConcordVenuePlatformLifecycle"))
    #expect(bridge.contains("WowApplication"))
    let activity = AndroidRendererTemplate.mainActivity(packageName: "com.example.wow")
    #expect(activity.contains("ConcordNative.rasterImageX"))
}

@Test
func experimentalRepositoryBecomesSwiftDependency() {
    let manifest = AndroidProjectTemplate.packageSwift(
        applicationType: "WowApplication",
        repository: "https://github.com/Zodiac-Innovations/ConcordUIExperiment.git",
        branch: "experiment"
    )
    #expect(manifest.contains("ConcordUIExperiment"))
    #expect(manifest.contains("branch: \"experiment\""))
}
