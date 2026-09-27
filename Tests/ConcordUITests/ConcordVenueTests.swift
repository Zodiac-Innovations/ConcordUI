import Foundation
import Testing
@testable import ConcordUI

private final class VenueTestPlatform: ConcordPlatform, ConcordVenuePlatformLifecycle, ConcordPlatformFileSupport {
    var displayedPresentation: ConcordPresentation?
    var closedVenue: ConcordVenue?
    var dismissedVenue: ConcordVenue?
    var launchedURL: URL?
    var openedResource: (name: String, type: ConcordResourceType)?
    var appName: String { "Venue Test" }
    var appVersion: String = "1.0"
    var appBuild: String = "1"
    var deviceType: ConcordDeviceType = .mobile
    var persistentValues: [String: Data] = [:]
    var canRetrieveResources: Bool { false }
    var canOpenResources: Bool { true }
    var canShareResources: Bool { false }

    func resourceShare(name: String, type: ConcordResourceType) -> Bool { false }
    func shareTextContent(_ text: String) -> Bool { false }
    func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool { false }

    func launchURL(_ url: URL) -> Bool {
        launchedURL = url
        return true
    }

    func resourceOpen(name: String, type: ConcordResourceType) -> Bool {
        openedResource = (name, type)
        return true
    }

    func setPersistentData(_ data: Data, forKey key: String) -> Bool {
        persistentValues[key] = data
        return true
    }

    func persistentData(forKey key: String) -> Data? {
        persistentValues[key]
    }

    func removePersistentValue(forKey key: String) -> Bool {
        persistentValues.removeValue(forKey: key)
        return true
    }

    func displayPresentation(_ presentation: ConcordPresentation) {
        displayedPresentation = presentation
    }

    func refreshPresentation(_ presentation: ConcordPresentation) {}

    func closeVenue(_ venue: ConcordVenue) {
        closedVenue = venue
    }

    func dismissVenue(_ venue: ConcordVenue) {
        dismissedVenue = venue
    }
}

@Test("Application owns one configured Main Venue")
func applicationOwnsOneMainVenue() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let config = application.mainVenue.config

    #expect(application.mainVenue.id == ConcordVenueID.main)
    #expect(application.mainVenue.id == "concordui.main")
    #expect(application.mainVenue.application === application)
    #expect(application.mainVenue.currentPresentation == nil)
    #expect(application.mainVenue.isDisplayed == false)
    #expect(config.kind == .main)
    #expect(config.name == "Venue Test")
    #expect(config.closable == false)
    #expect(config.dismissAble == false)
    #expect(config.closeLabel == nil)
    #expect(config.initialSize == ConcordVenueSize(640, 480))
    #expect(config.minSize == ConcordVenueSize(320, 240))
    #expect(config.maxSize == ConcordVenueSize(1280, 960))
}

@Test("ConcordUI Venue namespace is reserved")
func concordUIVenueNamespaceIsReserved() {
    #expect(ConcordVenueID.isReserved("concordui.main"))
    #expect(ConcordVenueID.isReserved("concordui-about"))
    #expect(ConcordVenueID.isReserved("concordui-get-started"))
    #expect(ConcordVenueID.isReserved("concordui-faq"))
    #expect(ConcordVenueID.isReserved("concordui.settings"))
    #expect(!ConcordVenueID.isReserved("venueshowcase.tools"))
}

@Test("Venue configuration supports fluent overrides")
func venueConfigurationSupportsFluentOverrides() {
    let application = ConcordApplication(platform: VenueTestPlatform())

    application.mainVenue
        .venue(name: "Main Window")
        .size(800, 600)
        .minSize(400, 300)
        .maxSize(1600, 1200)
        .closable(true)

    let config = application.mainVenue.config
    #expect(config.name == "Main Window")
    #expect(config.initialSize == ConcordVenueSize(800, 600))
    #expect(config.minSize == ConcordVenueSize(400, 300))
    #expect(config.maxSize == ConcordVenueSize(1600, 1200))
    #expect(config.closable)
}

@Test("Main Venue displays a Presentation")
func mainVenueDisplaysPresentation() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let presentation = ConcordPresentation { ConcordLabel("Main") }

    application.mainVenue.displayPresentation(presentation)

    #expect(application.currentPresentation === presentation)
    #expect(application.mainVenue.currentPresentation === presentation)
    #expect(presentation.venue === application.mainVenue)
    #expect(application.mainVenue.isDisplayed)
    #expect(platform.displayedPresentation === presentation)
}

@Test("Replacing Main Venue Presentation clears prior Venue relationship")
func replacingMainVenuePresentationClearsPriorVenue() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let first = ConcordPresentation { ConcordLabel("First") }
    let second = ConcordPresentation { ConcordLabel("Second") }

    application.mainVenue.displayPresentation(first)
    application.mainVenue.displayPresentation(second)

    #expect(first.venue == nil)
    #expect(second.venue === application.mainVenue)
    #expect(application.mainVenue.currentPresentation === second)
}

@Test("Venue registration builds fresh Presentations")
func venueRegistrationBuildsFreshPresentations() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    application.mainVenue.registerPresentation(tag: 10) { data in
        ConcordPresentation(tag: 10, data: data) { ConcordLabel("Registered") }
    }

    let first = application.mainVenue.displayPresentation(tag: 10)
    let second = application.mainVenue.displayPresentation(tag: 10)

    #expect(first != nil)
    #expect(second != nil)
    #expect(first !== second)
    #expect(second?.venue === application.mainVenue)
}

@Test("Application creates and looks up Secondary Venues without displaying them")
func applicationCreatesAndLooksUpSecondaryVenues() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let toolsConfig = ConcordVenueConfig(
        kind: .secondary,
        name: "Tools",
        closable: true,
        initialSize: ConcordVenueSize(500, 400),
        minSize: ConcordVenueSize(300, 250),
        maxSize: ConcordVenueSize(800, 700)
    )

    let first = application.createSecondaryVenue(id: "test.tools", config: toolsConfig)
    let second = application.createSecondaryVenue(
        id: "test.inspector",
        config: ConcordVenueConfig(kind: .secondary, name: "Inspector")
    )

    #expect(first !== second)
    #expect(application.secondaryVenues.count == 2)
    #expect(first.id == "test.tools")
    #expect(second.id == "test.inspector")
    #expect(application.secondaryVenue(id: "test.tools") === first)
    #expect(application.secondaryVenue(id: "test.inspector") === second)
    #expect(application.secondaryVenue(id: "test.missing") == nil)
    #expect(first.application === application)
    #expect(second.application === application)
    #expect(first.config == toolsConfig)
    #expect(first.isDisplayed == false)
    #expect(second.isDisplayed == false)
}

@Test("Secondary Venue close delegates to the platform without removing the Venue")
func secondaryVenueCloseDelegatesToPlatform() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let venue = application.createSecondaryVenue(
        id: "test.close",
        config: ConcordVenueConfig(kind: .secondary, name: "Close Test")
    )
    let presentation = ConcordPresentation { ConcordLabel("Secondary") }

    venue.displayPresentation(presentation)
    venue.closeVenue()

    #expect(platform.closedVenue === venue)
    #expect(application.secondaryVenue(id: "test.close") === venue)
    #expect(venue.currentPresentation === presentation)
}

@Test("Removing a Secondary Venue dismisses native realization and removes lookup")
func removingSecondaryVenueRemovesLookup() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let venue = application.createSecondaryVenue(
        id: "test.removable",
        config: ConcordVenueConfig(kind: .secondary)
    )

    #expect(application.secondaryVenue(id: "test.removable") === venue)
    application.removeSecondaryVenue(id: "test.removable")
    #expect(platform.dismissedVenue === venue)
    #expect(application.secondaryVenue(id: "test.removable") == nil)
}

@Test("Framework can create reserved Secondary Venues")
func frameworkCanCreateReservedSecondaryVenues() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let about = application.createSystemSecondaryVenue(
        id: ConcordVenueID.about,
        config: ConcordVenueConfig(kind: .secondary, name: "About")
    )

    #expect(about.id == "concordui-about")
    #expect(application.secondaryVenue(id: ConcordVenueID.about) === about)
}

@Test("Any Venue can create an owned Modal Venue")
func venueCreatesModalVenue() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let secondary = application.createSecondaryVenue(
        id: "test.secondary",
        config: ConcordVenueConfig(kind: .secondary)
    )

    let mainModal = application.mainVenue.createModalVenue(flavor: .dialog)
    let secondaryModal = secondary.createModalVenue(flavor: .sheet)

    #expect(mainModal.ownerVenue === application.mainVenue)
    #expect(secondaryModal.ownerVenue === secondary)
    #expect(mainModal.application === application)
    #expect(secondaryModal.application === application)
    #expect(mainModal.config.kind == .modal)
    #expect(secondaryModal.config.kind == .modal)
    #expect(mainModal.flavor == .dialog)
    #expect(secondaryModal.flavor == .sheet)
    #expect(mainModal.id.hasPrefix("modal."))
    #expect(secondaryModal.id.hasPrefix("modal."))
    #expect(mainModal.id != secondaryModal.id)
}

@Test("Modal Venue dismissal is explicit and releases its owner")
func modalVenueDismissesExplicitly() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let modal = application.mainVenue.createModalVenue(flavor: .dialog)
    let presentation = ConcordPresentation {
        ConcordVStack([ConcordText("Modal")])
    }

    modal.displayPresentation(presentation)

    #expect(modal.currentPresentation === presentation)
    #expect(platform.dismissedVenue == nil)
    #expect((presentation.root as? ConcordVStack)?.elements.count == 1)

    modal.dismiss()

    #expect(platform.dismissedVenue === modal)
    #expect(modal.currentPresentation == nil)
    #expect(modal.ownerVenue == nil)
}

@Test("Home is registered on Main Venue and displayHome uses it")
func homeUsesMainVenueRegistration() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)

    application.registerHome { data in
        ConcordPresentation(data: data) { ConcordLabel("Home") }
    }
    application.displayHome()

    #expect(application.currentPresentation != nil)
    #expect(application.currentPresentation?.venue === application.mainVenue)
    #expect(platform.displayedPresentation === application.currentPresentation)
}

@Test("Standard app start displays the Main Venue Home Presentation")
func standardAppStartDisplaysHome() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.registerHome { _ in
        ConcordPresentation { ConcordLabel("Standard Home") }
    }

    application.standardAppStart()

    #expect(application.currentPresentation?.venue === application.mainVenue)
    #expect((application.currentPresentation?.root as? ConcordLabel)?.text == "Standard Home")
    #expect(platform.displayedPresentation === application.currentPresentation)

    application.completeStandardAppStart()
    #expect(platform.displayedPresentation === application.currentPresentation)
}

@Test("Standard app start prefers Get Started on the first launch")
func standardAppStartShowsGetStartedFirst() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    var getStartedCount = 0
    var whatsNewCount = 0
    application.registerHome { _ in ConcordPresentation { ConcordLabel("Home") } }
    application.getStartedFeature = ConcordFeatureConfig(action: { getStartedCount += 1 })
    application.whatsNewFeature = ConcordFeatureConfig(action: { whatsNewCount += 1 })

    application.standardAppStart()

    #expect(application.isFirstTimeLaunch)
    #expect(application.isFirstTimeNewVersion)
    #expect((application.currentPresentation?.root as? ConcordLabel)?.text == "Home")
    #expect(getStartedCount == 0)
    #expect(whatsNewCount == 0)

    application.completeStandardAppStart()
    #expect(getStartedCount == 1)
    #expect(whatsNewCount == 0)

    application.completeStandardAppStart()
    #expect(getStartedCount == 1)
}

@Test("Standard app start prefers Welcome over Get Started on the first launch")
func standardAppStartPrefersWelcome() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    var welcomeCount = 0
    var getStartedCount = 0
    application.registerHome { _ in ConcordPresentation { ConcordLabel("Home") } }
    application.welcomeFeature = ConcordFeatureConfig(action: { welcomeCount += 1 })
    application.getStartedFeature = ConcordFeatureConfig(action: { getStartedCount += 1 })

    application.standardAppStart()

    #expect((application.currentPresentation?.root as? ConcordLabel)?.text == "Home")
    #expect(welcomeCount == 0)
    #expect(getStartedCount == 0)

    application.completeStandardAppStart()
    #expect(welcomeCount == 1)
    #expect(getStartedCount == 0)
}

@Test("First-launch Welcome continues to Get Started")
func firstLaunchWelcomeContinuesToGetStarted() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    var getStartedCount = 0

    application.registerHome { _ in
        ConcordPresentation { ConcordLabel("Home") }
    }
    application.useStandardWelcomeFeature(
        images: [.asset("welcome")]
    )
    application.getStartedFeature = ConcordFeatureConfig(
        action: { getStartedCount += 1 }
    )

    application.standardAppStart()
    #expect((application.currentPresentation?.root as? ConcordLabel)?.text == "Home")

    application.completeStandardAppStart()

    let welcomeVenue = application.secondaryVenue(id: ConcordVenueID.welcome)
    let root = welcomeVenue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack
    let continueButton = workStack?.bottom.elements.first as? ConcordButton

    #expect(continueButton?.title == ConcordString.continueText)
    #expect(workStack?.bottom.horizontalJustification == .center)
    #expect(getStartedCount == 0)

    continueButton?.activate()

    #expect(platform.closedVenue === welcomeVenue)
    #expect(getStartedCount == 1)
}

@Test("Standard app start shows What's New for a new version")
func standardAppStartShowsWhatsNewForNewVersion() {
    let platform = VenueTestPlatform()
    _ = ConcordApplication(platform: platform)

    platform.appBuild = "2"
    let buildOnlyApplication = ConcordApplication(platform: platform)
    #expect(!buildOnlyApplication.isFirstTimeNewVersion)

    platform.appVersion = "2.0"
    let application = ConcordApplication(platform: platform)
    var whatsNewCount = 0
    application.registerHome { _ in ConcordPresentation { ConcordLabel("Home") } }
    application.whatsNewFeature = ConcordFeatureConfig(action: { whatsNewCount += 1 })

    application.standardAppStart()

    #expect(!application.isFirstTimeLaunch)
    #expect(application.isFirstTimeNewVersion)
    #expect(whatsNewCount == 0)

    application.completeStandardAppStart()
    #expect(whatsNewCount == 1)
}

@Test("Launch reset APIs affect the next application launch")
func launchResetAPIsAffectNextLaunch() {
    let platform = VenueTestPlatform()
    _ = ConcordApplication(platform: platform)
    let existingApplication = ConcordApplication(platform: platform)

    #expect(existingApplication.resetFirstTimeLaunch())
    let resetStartApplication = ConcordApplication(platform: platform)
    #expect(resetStartApplication.isFirstTimeLaunch)

    #expect(resetStartApplication.resetFirstTimeNewVersion())
    let resetVersionApplication = ConcordApplication(platform: platform)
    #expect(!resetVersionApplication.isFirstTimeLaunch)
    #expect(resetVersionApplication.isFirstTimeNewVersion)
}

@Test("About button invokes the current app About action")
func aboutButtonInvokesCurrentFeature() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let button = application.concordAboutFeatureButton(flavor: .icon)
    var invocations = 0

    #expect(application.aboutFeature == nil)
    #expect(button.flavor == .icon)
    #expect(button.title == "About Venue Test")
    button.activate()
    #expect(invocations == 0)

    application.aboutFeature = ConcordFeatureConfig(title: "About Demo", action: { invocations += 1 })
    application.showAboutFeature()
    button.activate()
    #expect(invocations == 2)

    let titledButton = application.concordAboutFeatureButton(flavor: .icon)
    #expect(titledButton.accessibilityText == "About Demo")

    application.aboutFeature = nil
    button.activate()
    #expect(invocations == 2)
}

@Test("About Presentation uses one managed Secondary Venue with preferred size")
func aboutPresentationUsesManagedVenue() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    var builds = 0
    application.aboutFeature = ConcordFeatureConfig(
        title: "User Guide",
        presentation: {
            builds += 1
            return ConcordPresentation { ConcordLabel("About content") }
        },
        preferredWindowSize: (width: 720, height: 540)
    )

    application.showAboutFeature()
    let venue = application.secondaryVenue(id: ConcordVenueID.about)
    let first = venue?.currentPresentation

    #expect(ConcordVenueID.about == "concordui-about")
    #expect(venue != nil)
    #expect(venue?.config.name == "User Guide")
    #expect(venue?.config.initialSize == ConcordVenueSize(720, 540))
    #expect(venue?.config.closable == true)
    #expect(first?.venue === venue)
    #expect(platform.displayedPresentation === first)

    application.showAboutFeature()
    #expect(builds == 2)
    #expect(application.secondaryVenues.count == 1)
    #expect(venue?.currentPresentation !== first)
}

@Test("Generic feature configuration reuses one managed Secondary Venue")
func genericFeatureConfigurationUsesManagedVenue() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    var builds = 0
    let config = ConcordFeatureConfig(
        title: "Help",
        presentation: {
            builds += 1
            return ConcordPresentation { ConcordLabel("Help content") }
        },
        preferredWindowSize: (width: 640, height: 480),
        dismissAble: true,
        closeLabel: "Done"
    )

    application.showFeature(key: ConcordVenueID.help, config: config)
    let venue = application.secondaryVenue(id: ConcordVenueID.help)
    let first = venue?.currentPresentation

    #expect(venue?.config.name == "Help")
    #expect(venue?.config.initialSize == ConcordVenueSize(640, 480))
    #expect(venue?.config.dismissAble == true)
    #expect(venue?.config.closeLabel == "Done")
    #expect(first?.venue === venue)

    application.showFeature(key: ConcordVenueID.help, config: config)
    #expect(builds == 2)
    #expect(application.secondaryVenues.count == 1)
    #expect(venue?.currentPresentation !== first)
}

@Test("Welcome button invokes the current app feature")
func welcomeButtonInvokesCurrentFeature() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let button = application.concordWelcomeFeatureButton(flavor: .icon)
    var invocations = 0

    #expect(application.welcomeFeature == nil)
    #expect(button.flavor == .icon)
    #expect(button.accessibilityText == "Welcome to Venue Test")
    button.activate()
    #expect(invocations == 0)

    application.welcomeFeature = ConcordFeatureConfig(action: { invocations += 1 })
    application.showWelcomeFeature()
    button.activate()
    #expect(invocations == 2)
}

@Test("Standard Welcome uses adaptive overlapping images")
func standardWelcomeUsesAdaptiveOverlappingImages() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let images: [ConcordImageData] = [
        .asset("welcome-about"),
        .asset("welcome-getstarted"),
        .asset("welcome-whatsnew")
    ]
    application.useStandardWelcomeFeature(
        images: images,
        subHeader: "Build once for every platform."
    )
    application.showWelcomeFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.welcome)
    let root = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack
    let heading = workStack?.main.elements.first as? ConcordText
    let divider = workStack?.main.elements.dropFirst().first as? ConcordDivider
    let subHeader = workStack?.main.elements.dropFirst(2).first as? ConcordText
    let overlapping = workStack?.main.elements.last as? ConcordOverlappingImagesElement

    #expect(ConcordVenueID.welcome == "concordui-welcome")
    #expect(venue?.config.name == "Welcome to Venue Test")
    #expect(venue?.config.initialSize == ConcordVenueSize(800, 600))
    #expect(venue?.config.dismissAble == true)
    #expect(heading?.text == "Welcome to Venue Test")
    #expect(divider != nil)
    #expect(subHeader?.text == "Build once for every platform.")
    #expect(overlapping?.flavor == .bottomLeftToTopRight)
    #expect(overlapping?.images == images)
    #expect(workStack?.bottom.elements.isEmpty == true)

    platform.deviceType = .desktop
    application.showWelcomeFeature()
    let desktopWorkStack = venue?.currentPresentation?.root as? ConcordWorkStack
    let desktopOverlapping = desktopWorkStack?.main.elements.last as? ConcordOverlappingImagesElement
    #expect(desktopOverlapping?.flavor == .stacked)
}

@Test("Get Started button invokes the current app feature")
func getStartedButtonInvokesCurrentFeature() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let button = application.concordGetStartedFeatureButton(flavor: .icon)
    var invocations = 0

    #expect(application.getStartedFeature == nil)
    #expect(button.flavor == .icon)
    #expect(button.accessibilityText == "Get Started")
    button.activate()
    #expect(invocations == 0)

    application.getStartedFeature = ConcordFeatureConfig(
        title: "Welcome",
        action: { invocations += 1 }
    )
    application.showGetStartedFeature()
    button.activate()
    #expect(invocations == 2)

    let titledButton = application.concordGetStartedFeatureButton(flavor: .icon)
    #expect(titledButton.accessibilityText == "Welcome")
}

@Test("Standard Get Started displays summaries and access actions")
func standardGetStartedDisplaysSummariesAndAccess() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.useStandardGetStartedFeature(
        summaries: [
            ConcordSummaryData(
                image: .icon(.settings),
                title: "Custom Themes",
                description: "Apply colors and text styles."
            )
        ],
        centerAccess: ConcordAccessData(
            title: "Complete Feature List",
            link: "https://example.com/features"
        ),
        accessList: [
            ConcordAccessData(title: "Website", link: "https://example.com")
        ]
    )

    application.showGetStartedFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.getStarted)
    let root = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack
    let heading = workStack?.main.elements.first as? ConcordText
    let divider = workStack?.main.elements.dropFirst().first as? ConcordDivider
    let summaryRow = workStack?.main.elements.dropFirst(2).first as? ConcordHStack
    let summaryImage = summaryRow?.elements.first as? ConcordImage
    let summaryText = summaryRow?.elements.last as? ConcordVStack
    let centerAccessButton = workStack?.main.elements.last as? ConcordAccessButton
    let accessButton = workStack?.bottom.elements.compactMap { $0 as? ConcordAccessButton }.first

    #expect(ConcordVenueID.getStarted == "concordui-get-started")
    #expect(venue?.config.name == "Get Started")
    #expect(venue?.config.dismissAble == true)
    #expect(heading?.text == "Get Started")
    #expect(divider != nil)
    #expect(summaryImage?.imageData == .icon(.settings))
    #expect(summaryImage?.foregroundColor == .accent)
    #expect((summaryText?.elements.first as? ConcordText)?.text == "Custom Themes")
    #expect((summaryText?.elements.last as? ConcordText)?.text == "Apply colors and text styles.")
    #expect(centerAccessButton?.title == "Complete Feature List")
    #expect(centerAccessButton?.presentation == .link)
    #expect(centerAccessButton?.foregroundColor == .accent)
    #expect(accessButton?.title == "Website")
    #expect(accessButton?.presentation == .button)
    #expect(workStack?.bottom.horizontalJustification == .center)
    #expect(workStack?.bottom.elements.count == 3)
    #expect(workStack?.bottom.elements.first is ConcordSpacer)
    #expect(workStack?.bottom.elements.last is ConcordSpacer)
}

@Test("Mobile Get Started leaves footer access left without center access")
func standardGetStartedLeavesAccessLeftWithoutCenterAccess() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.useStandardGetStartedFeature(
        summaries: [],
        accessList: [
            ConcordAccessData(title: "Website", link: "https://example.com")
        ]
    )

    application.showGetStartedFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.getStarted)
    let root = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack

    #expect(workStack?.bottom.horizontalJustification == .left)
    #expect(workStack?.bottom.elements.count == 1)
    #expect(workStack?.bottom.elements.first is ConcordAccessButton)
}

@Test("What's New button invokes the current app feature")
func whatsNewButtonInvokesCurrentFeature() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let button = application.concordWhatsNewFeatureButton(flavor: .icon)
    var invocations = 0

    #expect(application.whatsNewFeature == nil)
    #expect(button.flavor == .icon)
    #expect(button.accessibilityText == "What's New")
    button.activate()
    #expect(invocations == 0)

    application.whatsNewFeature = ConcordFeatureConfig(action: { invocations += 1 })
    application.showWhatsNewFeature()
    button.activate()
    #expect(invocations == 2)
}

@Test("Standard What's New displays center and footer access")
func standardWhatsNewDisplaysContent() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.useStandardWhatsNewFeature(
        summaries: [
            ConcordSummaryData(
                image: .icon(.add),
                title: "Enhanced Layout",
                description: "New auto-align rules."
            )
        ],
        centerAccess: ConcordAccessData(
            title: "Complete Feature List",
            link: "https://example.com/features"
        ),
        accessList: [
            ConcordAccessData(title: "Website", link: "https://example.com")
        ]
    )

    application.showWhatsNewFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.whatsNew)
    let presentationRoot = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = presentationRoot?.elements.first as? ConcordWorkStack
    let heading = workStack?.main.elements.first as? ConcordText
    let summaryRow = workStack?.main.elements.dropFirst(2).first as? ConcordHStack
    let centerAccessButton = workStack?.main.elements.last as? ConcordAccessButton
    let footerAccessButton = workStack?.bottom.elements.compactMap { $0 as? ConcordAccessButton }.first
    let okButton = presentationRoot?.elements.last as? ConcordButton

    #expect(venue?.config.name == "What's New in Venue Test")
    #expect(venue?.config.dismissAble == true)
    #expect(heading?.text == "What's New in Venue Test")
    #expect((summaryRow?.elements.first as? ConcordImage)?.foregroundColor == .accent)
    #expect(centerAccessButton?.title == "Complete Feature List")
    #expect(centerAccessButton?.presentation == .link)
    #expect(footerAccessButton?.title == "Website")
    #expect(footerAccessButton?.presentation == .button)
    #expect(workStack?.bottom.elements.count == 3)
    #expect(workStack?.bottom.elements.first is ConcordSpacer)
    #expect(workStack?.bottom.elements.last is ConcordSpacer)
    #expect(workStack?.bottom.horizontalJustification == .center)
    #expect(okButton?.title == ConcordString.ok)
    #expect(okButton?.horizontalJustification == .center)

    okButton?.activate()
    #expect(platform.closedVenue === venue)
}

@Test("FAQ button invokes the current app feature")
func faqButtonInvokesCurrentFeature() {
    let application = ConcordApplication(platform: VenueTestPlatform())
    let button = application.concordFAQFeatureButton(flavor: .icon)
    var invocations = 0

    #expect(application.faqFeature == nil)
    #expect(button.flavor == .icon)
    #expect(button.accessibilityText == "FAQ for Venue Test")
    button.activate()
    #expect(invocations == 0)

    application.faqFeature = ConcordFeatureConfig(action: { invocations += 1 })
    application.showFAQFeature()
    button.activate()
    #expect(invocations == 2)
}

@Test("Standard FAQ groups expandable questions and access actions")
func standardFAQDisplaysQuestionsAndAccess() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.useStandardFAQFeature(
        data: ConcordFAQFeatureData(sections: [
            ConcordQAListData(
                title: "Getting Started",
                questions: [
                    ConcordQAData(
                        question: "How do I save?",
                        answer: "Choose File > Save.",
                        access: [
                            ConcordAccessData(
                                title: "User Guide",
                                link: "https://example.com/guide"
                            )
                        ]
                    )
                ]
            ),
            ConcordQAListData(
                title: "",
                questions: [
                    ConcordQAData(
                        question: "Does this work everywhere?",
                        answer: "Yes."
                    )
                ]
            )
        ]),
        accessList: [
            ConcordAccessData(title: "License", link: "https://example.com/license")
        ]
    )

    application.showFAQFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.faq)
    let root = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack
    let groupTitle = workStack?.main.elements.first as? ConcordText
    let firstQuestion = workStack?.main.elements.dropFirst().first as? ConcordExpander
    let answer = firstQuestion?.elements.first as? ConcordText
    let answerAccess = firstQuestion?.elements.last as? ConcordAccessButton
    let secondQuestion = workStack?.main.elements.last as? ConcordExpander
    let footerAccess = workStack?.bottom.elements.compactMap { $0 as? ConcordAccessButton }.first

    #expect(ConcordVenueID.faq == "concordui-faq")
    #expect(venue?.config.name == "FAQ for Venue Test")
    #expect(venue?.config.dismissAble == true)
    #expect(workStack?.main.edge == 0)
    #expect(groupTitle?.text == "Getting Started")
    #expect(groupTitle?.textStyle?.isBold == true)
    #expect(firstQuestion?.label == "Q: How do I save?")
    #expect(firstQuestion?.onRight == false)
    #expect(firstQuestion?.labelIsBold == true)
    #expect(firstQuestion?.isExpanded == false)
    #expect(answer?.text == "A: Choose File > Save.")
    #expect(answerAccess?.title == "User Guide")
    #expect(answerAccess?.presentation == .link)
    #expect(secondQuestion?.label == "Q: Does this work everywhere?")
    #expect(footerAccess?.title == "License")
    #expect(workStack?.bottom.horizontalJustification == .left)
    #expect(workStack?.bottom.elements.count == 1)

    firstQuestion?.toggleExpanded()
    #expect(firstQuestion?.isExpanded == true)

    platform.deviceType = .desktop
    application.showFAQFeature()
    let desktopWorkStack = venue?.currentPresentation?.root as? ConcordWorkStack
    #expect(desktopWorkStack?.main.edge == 20)
}

@Test("Access buttons open URLs and bundled files from the presenting application")
func accessButtonsOpenTheirDestinations() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let link = ConcordAccessData(title: "Website", link: "https://example.com/about")
    let file = ConcordAccessData(title: "License", file: "License.pdf")
    let linkButton = ConcordAccessButton(access: link)
    let fileButton = ConcordAccessButton(access: file)
    let presentation = ConcordPresentation {
        ConcordVStack([linkButton, fileButton])
    }

    application.displayMainPresentation(presentation)
    linkButton.activate()
    fileButton.activate()

    #expect(linkButton.title == "Website")
    #expect(platform.launchedURL?.absoluteString == "https://example.com/about")
    #expect(platform.openedResource?.name == "License")
    #expect(platform.openedResource?.type == .pdf)
}

@Test("Common About convenience creates conventional URL access actions")
func commonAboutConvenienceCreatesAccessActions() {
    let platform = VenueTestPlatform()
    platform.deviceType = .desktop
    let application = ConcordApplication(platform: platform)
    application.useStandardAboutFeature(
        urlAcknowledgements: "https://example.com/acknowledgements",
        urlLicenseAgreement: "https://example.com/license"
    )

    application.showAboutFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.about)
    let workStack = venue?.currentPresentation?.root as? ConcordWorkStack
    let acknowledgements = workStack?.bottom.elements.first as? ConcordAccessButton
    let license = workStack?.bottom.elements.last as? ConcordAccessButton

    #expect(workStack?.bottom.elements.count == 2)
    #expect(acknowledgements?.title == "Acknowledgements")
    #expect(acknowledgements?.access.link == "https://example.com/acknowledgements")
    #expect(license?.title == "License Agreement")
    #expect(license?.access.link == "https://example.com/license")

    application.useStandardAboutFeature(
        urlAcknowledgements: nil,
        urlLicenseAgreement: nil
    )
    application.showAboutFeature()
    let emptyWorkStack = venue?.currentPresentation?.root as? ConcordWorkStack
    #expect(emptyWorkStack?.bottom.elements.isEmpty == true)
}

@Test("Standard About opens in a managed venue and dismisses on mobile")
func standardAboutDisplaysAccessAndCloses() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    application.useStandardAboutFeature(accessList: [
        ConcordAccessData(title: "License Agreement", file: "License.pdf")
    ])

    application.showAboutFeature()

    let venue = application.secondaryVenue(id: ConcordVenueID.about)
    let root = venue?.currentPresentation?.root as? ConcordVStack
    let workStack = root?.elements.first as? ConcordWorkStack
    let identity = workStack?.main.elements.first as? ConcordABStack
    let accessButton = workStack?.bottom.elements.compactMap { $0 as? ConcordAccessButton }.first
    let okButton = root?.elements.last as? ConcordButton

    #expect(venue?.config.initialSize == ConcordVenueSize(576, 354))
    #expect(venue?.config.dismissAble == true)
    #expect(workStack?.bottomHeight == ConcordWorkStack.defaultBottomHeight)
    #expect(workStack?.bottom.horizontalJustification == .left)
    #expect(workStack?.bottom.elements.count == 1)
    #expect(workStack?.bottom.elements.first is ConcordAccessButton)
    #expect(identity?.aFraction == 0.4)
    #expect((identity?.a.elements.first as? ConcordImage)?.fillsSquare == true)
    #expect(accessButton?.title == "License Agreement")
    #expect(accessButton?.flavor == .text)
    #expect(okButton?.title == ConcordString.ok)
    #expect(okButton?.horizontalJustification == .center)

    accessButton?.activate()
    #expect(platform.openedResource?.name == "License")
    okButton?.activate()
    #expect(platform.closedVenue === venue)
}

@Test("Secondary Venue dismissal uses closeLabel and is omitted on desktop")
func venueDismissControlHonorsConfigAndDevice() {
    let platform = VenueTestPlatform()
    let application = ConcordApplication(platform: platform)
    let venue = application.createSecondaryVenue(
        id: "test.dismiss",
        config: ConcordVenueConfig(
            kind: .secondary,
            dismissAble: true,
            closeLabel: "Close"
        )
    )
    venue.displayPresentation(ConcordPresentation { ConcordText("Details") })
    let mobileRoot = venue.currentPresentation?.root as? ConcordVStack
    let closeButton = mobileRoot?.elements.last as? ConcordButton

    #expect(closeButton?.title == "Close")
    #expect(closeButton?.horizontalJustification == .center)
    closeButton?.activate()
    #expect(platform.closedVenue === venue)

    platform.deviceType = .desktop
    venue.displayPresentation(ConcordPresentation { ConcordText("Details") })
    #expect(venue.currentPresentation?.root is ConcordText)
}
