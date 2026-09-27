import Testing
@testable import ConcordUI

private final class ConditionalTestPlatform: ConcordPlatform {
    let platformType: ConcordPlatformType

    init(_ platformType: ConcordPlatformType) {
        self.platformType = platformType
    }

    func displayPresentation(_ presentation: ConcordPresentation) {}
    func refreshPresentation(_ presentation: ConcordPresentation) {}
}

@Test("Conditional lists preserve enabled elements and use a blank when disabled")
func conditionalListsSelectElements() {
    let label = ConcordLabel("Enabled")
    let enabled = isListOnFlag(true, [label])
    let disabled = isListOnFlag(false, [label])

    #expect(enabled.count == 1)
    #expect(enabled[0] === label)
    #expect(disabled.count == 1)
    #expect(disabled[0] is ConcordBlankElement)
}

@Test("Presentation recursively removes blank elements when built")
func presentationCleansBlankElements() {
    let platform = ConditionalTestPlatform(.iOS)
    let application = ConcordApplication(platform: platform)
    let nested = ConcordVStack(
        [ConcordLabel("Nested")] + isListOnFlag(false, [ConcordLabel("Hidden")])
    )
    let presentation = ConcordPresentation {
        ConcordVStack(
            isListOnFlag(false, [ConcordLabel("Hidden")]) + [nested]
        )
    }

    application.displayMainPresentation(presentation)

    let root = presentation.root as? ConcordVStack
    #expect(root?.elements.count == 1)
    #expect(root?.elements[0] === nested)
    #expect(nested.elements.count == 1)
    #expect(nested.elements[0] is ConcordLabel)
}

@Test("Platform list conveniences select only their matching platform")
func platformListConveniencesMatchPlatform() {
    let label = ConcordLabel("Platform")
    let iOS = ConditionalTestPlatform(.iOS)

    #expect(iOS.isIOSList([label])[0] === label)
    #expect(iOS.isAndroidList([label])[0] is ConcordBlankElement)
    #expect(iOS.isMacList([label])[0] is ConcordBlankElement)
    #expect(iOS.isWindowList([label])[0] is ConcordBlankElement)
}
