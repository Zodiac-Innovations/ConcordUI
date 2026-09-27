import Testing
@testable import ConcordUI

@Test("ConcordString supplies standard feature copy")
func concordStringSuppliesStandardFeatureCopy() {
    #expect(ConcordString.acknowledgements == "Acknowledgements")
    #expect(ConcordString.licenseAgreement == "License Agreement")
    #expect(ConcordString.getStarted == "Get Started")
    #expect(ConcordString.whatsNew == "What's New")
    #expect(ConcordString.continueText == "Continue")
    #expect(ConcordString.aboutTitle("Demo") == "About Demo")
    #expect(ConcordString.whatsNewTitle("Demo") == "What's New in Demo")
    #expect(ConcordString.versionBuild(version: "1.0", build: "2") == "Version 1.0 (2)")
}

@Test("ConcordString supplies standard state and fallback copy")
func concordStringSuppliesStandardStateCopy() {
    #expect(ConcordString.on == "On")
    #expect(ConcordString.off == "Off")
    #expect(ConcordString.undecided == "Undecided")
    #expect(ConcordString.application == "Application")
    #expect(ConcordString.unknown == "Unknown")
    #expect(ConcordString.nilValue == "nil")
    #expect(ConcordString.unavailableValue == "—")
}
