import Foundation
import Testing
@testable import ConcordUI

private final class TestPlatform: ConcordPlatform {
    var displayedPresentation: ConcordPresentation?
    var refreshedPresentation: ConcordPresentation?

    func displayPresentation(_ presentation: ConcordPresentation) { displayedPresentation = presentation }
    func refreshPresentation(_ presentation: ConcordPresentation) { refreshedPresentation = presentation }
}

private final class HandlingPresentation: ConcordPresentation {
    var handledEvent: ConcordActionEvent?
    override func handleAction(_ event: ConcordActionEvent) -> Bool { handledEvent = event; return true }
}

private final class LifecycleRecorder { var events: [String] = [] }
private final class LifecyclePresentation: ConcordPresentation {
    let recorder: LifecycleRecorder
    init(recorder: LifecycleRecorder, content: @escaping ConcordElementBuilder) { self.recorder = recorder; super.init(content) }
    override func startPresentation() { recorder.events.append("start") }
    override func finishPresentation() { recorder.events.append("finish") }
}

private final class TestData: ConcordDataProtocol {
    let value: String
    init(_ value: String) { self.value = value }
    func clone() -> Self { Self(value) }
}

@Test("Application stores singular and repeatable functionality")
func applicationStoresApplicationFunctionality() {
    let application = ConcordApplication(platform: TestPlatform())
    var buildCount = 0

    let configuredApplication = application
        .aboutPresentation {
            buildCount += 1
            return ConcordLabel("About")
        }
        .settingsPresentation(title: "Preferences") { ConcordLabel("Settings") }
        .welcomePresentation { ConcordLabel("Welcome") }
        .helpPresentation { ConcordLabel("Help") }
        .helpPresentation(position: 2, title: "What's New") { ConcordLabel("Changes") }
        .helpPresentation(position: 3, title: "Contact") { ConcordLabel("Contact") }
        .applicationMenu(title: "Project")
        .applicationPresentation(position: 1, title: "Import") { ConcordLabel("Import") }
        .applicationPresentation(position: 2, title: "Export") { ConcordLabel("Export") }

    #expect(configuredApplication === application)
    #expect(buildCount == 0)
    #expect(application.applicationFunctionality(.about)?.title == nil)
    #expect(application.applicationFunctionality(.settings)?.title == "Preferences")
    #expect(application.applicationFunctionality(.welcome) != nil)
    #expect(application.applicationFunctionalities(for: .help).map(\.position) == [1, 2, 3])
    #expect(application.applicationFunctionality(.help, position: 2)?.title == "What's New")
    #expect(application.applicationMenuTitle == "Project")
    #expect(application.applicationFunctionalities(for: .application).map(\.position) == [1, 2])

    let aboutRoot = application.applicationFunctionality(.about)?.buildElements()
    #expect(buildCount == 1)
    #expect((aboutRoot as? ConcordLabel)?.text == "About")
}

@Test("Main Venue displays presentation")
func coreMainVenueDisplaysPresentation() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform)
    let presentation = ConcordPresentation { ConcordText("Hello") }
    application.mainVenue.displayPresentation(presentation)
    #expect(platform.displayedPresentation === presentation)
    #expect(application.currentPresentation === presentation)
}

@Test("Element change refreshes current presentation")
func elementChangeRefreshesCurrentPresentation() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform)
    let label = ConcordLabel("Before"); let presentation = ConcordPresentation { ConcordVStack([label]) }
    application.mainVenue.displayPresentation(presentation); label.text = "After"
    #expect(platform.refreshedPresentation === presentation)
}

@Test("Venue registration builds fresh presentations")
func coreVenueRegistrationBuildsFreshPresentations() {
    let platform = TestPlatform(); let data = TestData("venue")
    let application = ConcordApplication(platform: platform, currentData: data)
    application.mainVenue.registerPresentation(tag: 100) { suppliedData in
        ConcordPresentation(tag: 100, data: suppliedData) { ConcordLabel("Detail") }
    }
    let first = application.mainVenue.displayPresentation(tag: 100)
    let second = application.mainVenue.displayPresentation(tag: 100)
    #expect(first != nil); #expect(second != nil); #expect(first !== second)
    #expect((first?.data as? TestData) === data)
    #expect(application.currentPresentation === second); #expect(platform.displayedPresentation === second)
}

@Test("Venue display data override wins")
func venueDisplayDataOverrideWins() {
    let platform = TestPlatform(); let defaultData = TestData("default"); let overrideData = TestData("override")
    let application = ConcordApplication(platform: platform, currentData: defaultData)
    application.mainVenue.registerPresentation(tag: 1) { data in ConcordPresentation(data: data) }
    let overridden = application.mainVenue.displayPresentation(tag: 1, data: overrideData)
    let normal = application.mainVenue.displayPresentation(tag: 1)
    #expect((overridden?.data as? TestData) === overrideData)
    #expect((normal?.data as? TestData) === defaultData)
}

@Test("Auxiliary Venue registrations are isolated")
func auxiliaryVenueRegistrationsAreIsolated() {
    let platform = TestPlatform(); let mainData = TestData("main"); let auxiliaryData = TestData("auxiliary")
    let application = ConcordApplication(platform: platform, currentData: mainData)
    let auxiliary = application.createAuxiliaryVenue(currentData: auxiliaryData)

    application.mainVenue.registerPresentation(tag: 10) { data in
        ConcordPresentation(tag: 10, data: data) { ConcordLabel("Main Presentation") }
    }
    auxiliary.registerPresentation(tag: 10) { data in
        ConcordPresentation(tag: 10, data: data) { ConcordLabel("Auxiliary Presentation") }
    }

    let mainPresentation = application.mainVenue.displayPresentation(tag: 10)
    let auxiliaryPresentation = auxiliary.displayPresentation(tag: 10)

    #expect((mainPresentation?.data as? TestData) === mainData)
    #expect((auxiliaryPresentation?.data as? TestData) === auxiliaryData)
    #expect(auxiliary.currentPresentation === auxiliaryPresentation)
}

@Test("Direct Venue display data override wins")
func directVenueDisplayDataOverrideWins() {
    let platform = TestPlatform(); let defaultData = TestData("default"); let overrideData = TestData("override")
    let application = ConcordApplication(platform: platform, currentData: defaultData); let presentation = ConcordPresentation()
    application.mainVenue.displayPresentation(presentation, data: overrideData)
    #expect((presentation.data as? TestData) === overrideData)
}

@Test("Presentation builds root element after start")
func presentationBuildsRootElementAfterStart() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform)
    let text = ConcordText("Hello"); let presentation = ConcordPresentation { text }
    #expect(presentation.root !== text); application.mainVenue.displayPresentation(presentation); #expect(presentation.root === text)
}

@Test("Presentation lifecycle starts before element build and finishes before replacement")
func presentationLifecycleOrder() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform); let recorder = LifecycleRecorder()
    let first = LifecyclePresentation(recorder: recorder) { recorder.events.append("build"); return ConcordLabel("First") }
    let second = ConcordPresentation { ConcordLabel("Second") }
    application.mainVenue.displayPresentation(first); #expect(recorder.events == ["start", "build"])
    application.mainVenue.displayPresentation(second); #expect(recorder.events == ["start", "build", "finish"])
}

@Test("Finished Presentation releases transient elements and rebuilds fresh tree")
func finishedPresentationRebuildsFreshTree() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform)
    let data = TestData("persistent"); var buildCount = 0
    let presentation = ConcordPresentation(tag: 77, name: "Reusable", data: data) {
        buildCount += 1
        return ConcordLabel("Build \(buildCount)").tagged(buildCount)
    }
    let other = ConcordPresentation { ConcordLabel("Other") }

    application.mainVenue.displayPresentation(presentation)
    let firstRoot = presentation.root
    #expect(presentation.element(tag: 1) === firstRoot)

    application.mainVenue.displayPresentation(other)
    #expect(presentation.root !== firstRoot)
    #expect(presentation.element(tag: 1) == nil)
    #expect(presentation.tag == 77)
    #expect(presentation.name == "Reusable")
    #expect((presentation.data as? TestData) === data)

    application.mainVenue.displayPresentation(presentation)
    let secondRoot = presentation.root
    #expect(secondRoot !== firstRoot)
    #expect(presentation.element(tag: 2) === secondRoot)
    #expect(buildCount == 2)
}

@Test("Container supports element management")
func containerSupportsElementManagement() {
    let first = ConcordLabel("First"); let second = ConcordLabel("Second"); let stack = ConcordVStack([first])
    stack.add(second); #expect(stack.elements.count == 2); #expect(stack.elements[0] === first); #expect(stack.elements[1] === second)
}

@Test("Vertical stack has a default edge inset")
func verticalStackHasDefaultEdgeInset() {
    let defaultStack = ConcordVStack(); let customStack = ConcordVStack(); customStack.edge = 24
    #expect(defaultStack.edge == 10); #expect(customStack.edge == 24)
}

@Test("Button activation event identifies type and source")
func buttonActivationEventIdentifiesTypeAndSource() {
    var receivedEvent: ConcordActionEvent?; let button = ConcordButton("Press", action: { event in receivedEvent = event })
    button.activate(); #expect(receivedEvent?.type == .buttonActivate); #expect(receivedEvent?.element === button)
}

@Test("Button event bubbles to presentation")
func buttonEventBubblesToPresentation() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform); let button = ConcordButton("Press")
    let presentation = HandlingPresentation { ConcordVStack([button]) }
    application.mainVenue.displayPresentation(presentation); button.activate()
    #expect(presentation.handledEvent?.type == .buttonActivate); #expect(presentation.handledEvent?.element === button)
}

@Test("Presentation can find nested elements by identity after display")
func presentationCanFindNestedElementsByIdentityAfterDisplay() {
    let platform = TestPlatform(); let application = ConcordApplication(platform: platform)
    let target = ConcordLabel("Target").named("target").tagged(42).positioned(7)
    let presentation = ConcordPresentation { ConcordVStack([ConcordText("Other"), ConcordVStack([target])]) }
    application.mainVenue.displayPresentation(presentation)
    #expect(presentation.element(id: target.id) === target); #expect(presentation.element(name: "target") === target)
    #expect(presentation.element(tag: 42) === target); #expect(presentation.element(position: 7) === target)
}


@Test("Platform exposes bundled ConcordUI image")
func platformExposesBundledConcordUIImage() {
    #expect(TestPlatform().concordImage() == .asset("concordui-1024"))
}


@Test("Title action element creates buttons for list and stack flavors")
func titleActionElementCreatesButtons() {
    var invoked: [String] = []
    let actions = [
        ConcordTitleAction("First") { invoked.append("first") },
        ConcordTitleAction("Second") { invoked.append("second") }
    ]

    let vertical = ConcordTitleActionElement(.vlist, actions: actions)
    let horizontal = ConcordTitleActionElement(.stack, actions: actions)

    #expect(vertical.flavor == .vlist)
    #expect(horizontal.flavor == .stack)
    #expect(vertical.elements.count == 2)
    #expect((vertical.elements[0] as? ConcordButton)?.title == "First")
    #expect((horizontal.elements[1] as? ConcordButton)?.title == "Second")

    (vertical.elements[0] as? ConcordButton)?.activate()
    (horizontal.elements[1] as? ConcordButton)?.activate()
    #expect(invoked == ["first", "second"])
}

@Test("Title action popup exposes its trigger and invokes selected action")
func titleActionPopupInvokesSelectedAction() {
    var selected = ""
    let popup = ConcordTitleActionElement(
        .popup,
        actions: [
            ConcordTitleAction("One") { selected = "one" },
            ConcordTitleAction("Two") { selected = "two" }
        ],
        label: "Choose",
        image: .icon(.settings)
    )

    #expect(popup.label == "Choose")
    if case .icon(.settings)? = popup.image {
        // Expected popup trigger image.
    } else {
        Issue.record("Expected settings popup image")
    }
    #expect(popup.actionCount == 2)
    #expect(popup.actionTitle(at: 1) == "Two")
    #expect(popup.actionTitle(at: 2) == nil)

    popup.activateAction(at: 1)
    #expect(selected == "two")

    popup.enabled(false)
    popup.activateAction(at: 0)
    #expect(selected == "two")
}


@Test("All Help button is blank when no Help features are configured")
func allHelpButtonIsBlankWithoutEntries() {
    let application = ConcordApplication(platform: TestPlatform())
    #expect(application.concordAllHelpButton() is ConcordBlankElement)
}

@Test("All Help button remains a popup for one feature")
func allHelpButtonRemainsPopupForSingleFeature() {
    let application = ConcordApplication(platform: TestPlatform())
    var invoked = false
    application.faqFeature = ConcordFeatureConfig(
        title: "Questions",
        action: { invoked = true }
    )

    guard let popup = application.concordAllHelpButton(
        title: "Assistance"
    ) as? ConcordTitleActionElement else {
        Issue.record("Expected a Help title-action popup")
        return
    }

    #expect(popup.flavor == .popup)
    #expect(popup.edge == 0)
    #expect(popup.label == "Assistance")
    #expect(popup.actionTitle(at: 0) == "Questions")
    #expect(
        (application.concordAllHelpButton() as? ConcordTitleActionElement)?.label
            == "Questions"
    )
    popup.activateAction(at: 0)
    #expect(invoked)
}

@Test("Help features popup follows macOS Help menu order")
func allHelpPopupFollowsMenuOrder() {
    let application = ConcordApplication(platform: TestPlatform())
    var invoked = ""
    application.helpFeature = ConcordFeatureConfig(
        title: "Help",
        action: { invoked = "help" }
    )
    application.welcomeFeature = ConcordFeatureConfig(
        title: "Welcome",
        action: { invoked = "welcome" }
    )
    application.getStartedFeature = ConcordFeatureConfig(
        title: "Begin",
        action: { invoked = "getStarted" }
    )
    application.whatsNewFeature = ConcordFeatureConfig(
        title: "Changes",
        action: { invoked = "whatsNew" }
    )
    application.faqFeature = ConcordFeatureConfig(
        title: "Questions",
        action: { invoked = "faq" }
    )
    application.addHelpAction(
        ConcordTitleAction("Support") {
            invoked = "support"
        }
    )

    guard let popup = application.concordAllHelpButton()
        as? ConcordTitleActionElement else {
        Issue.record("Expected a title-action popup")
        return
    }

    #expect(popup.flavor == .popup)
    #expect(popup.actionTitle(at: 0) == "Help")
    #expect(popup.actionTitle(at: 1) == "Welcome")
    #expect(popup.actionTitle(at: 2) == "Begin")
    #expect(popup.actionTitle(at: 3) == "Changes")
    #expect(popup.actionTitle(at: 4) == "Questions")
    #expect(popup.actionTitle(at: 5) == "Support")

    popup.activateAction(at: 5)
    #expect(invoked == "support")
}


@Test("Application collects Help access and direct actions")
func applicationCollectsHelpActions() {
    let application = ConcordApplication(platform: TestPlatform())
    var directlyInvoked = false

    let configured = application
        .addHelpAccess(
            ConcordAccessData(
                title: "Support Website",
                link: "https://example.com/support"
            )
        )
        .addHelpAction(
            ConcordTitleAction("Contact Support") {
                directlyInvoked = true
            }
        )

    #expect(configured === application)
    #expect(application.helpActions.map(\.title) == [
        "Support Website",
        "Contact Support"
    ])

    application.helpActions[1].invoke()
    #expect(directlyInvoked)
}

@Test("All Settings button handles zero one and multiple actions")
func allSettingButtonHandlesActionCounts() {
    let application = ConcordApplication(platform: TestPlatform())
    var invoked = ""

    #expect(application.concordAllSettingButton() is ConcordBlankElement)

    application.addSettingAction(
        ConcordTitleAction("General") {
            invoked = "general"
        }
    )
    guard let single = application.concordAllSettingButton(
        title: "Preferences"
    ) as? ConcordTitleActionElement else {
        Issue.record("Expected a Settings title-action popup")
        return
    }
    #expect(single.flavor == .popup)
    #expect(single.label == "Preferences")
    single.activateAction(at: 0)
    #expect(invoked == "general")

    application.addSettingAccess(
        ConcordAccessData(
            title: "Privacy Policy",
            link: "https://example.com/privacy"
        )
    )
    guard let popup = application.concordAllSettingButton()
        as? ConcordTitleActionElement else {
        Issue.record("Expected a Settings title-action popup")
        return
    }

    #expect(popup.flavor == .popup)
    #expect(popup.edge == 0)
    #expect(popup.actionTitle(at: 0) == "General")
    #expect(popup.actionTitle(at: 1) == "Privacy Policy")
}

@Test("Application Action Groups preserve menu order and place Special last")
func applicationActionGroupsPreserveMenuOrder() {
    let application = ConcordApplication(platform: TestPlatform())
    var invoked = ""

    application
        .createActionGroup(tag: "links", title: ConcordString.links)
        .createActionGroupItem(
            groupTag: "links",
            access: ConcordAccessData(
                title: "Website",
                link: "https://example.com"
            )
        )
        .createActionGroup(tag: "tools", title: "Tools")
        .createActionGroupItem(
            groupTag: "tools",
            action: ConcordTitleAction("Run") {
                invoked = "run"
            }
        )
        .createSpecialItem(
            action: ConcordTitleAction("Special Action") {
                invoked = "special"
            }
        )

    #expect(application.displayedActionGroups.map(\.tag) == [
        "links",
        "tools",
        ConcordActionGroup.specialTag
    ])
    #expect(application.displayedActionGroups.map(\.title) == [
        ConcordString.links,
        "Tools",
        ConcordString.special
    ])
    #expect(application.actionGroup(tag: "links")?.actions.first?.title == "Website")

    application.actionGroup(tag: "tools")?.actions.first?.invoke()
    #expect(invoked == "run")
    application.actionGroup(tag: ConcordActionGroup.specialTag)?.actions.first?.invoke()
    #expect(invoked == "special")
}

@Test("Empty Action Groups are omitted from menu order")
func emptyActionGroupsAreOmitted() {
    let application = ConcordApplication(platform: TestPlatform())
        .createActionGroup(tag: "empty", title: "Empty")

    #expect(application.actionGroup(tag: "empty") != nil)
    #expect(application.displayedActionGroups.isEmpty)
}

@Test("Action Group button resolves its application group")
func actionGroupButtonResolvesApplicationGroup() {
    let platform = TestPlatform()
    let application = ConcordApplication(platform: platform)
        .createActionGroup(tag: "links", title: ConcordString.links)
        .createActionGroupItem(
            groupTag: "links",
            action: ConcordTitleAction("Open") {}
        )
    let button = ConcordActionGroupButton(
        tag: "links",
        image: .icon(.search)
    )
    let presentation = ConcordPresentation { button }

    application.mainVenue.displayPresentation(presentation)

    #expect(button.resolvedActionGroup() === application.actionGroup(tag: "links"))
    #expect(button.resolvedActionGroup()?.actions.first?.title == "Open")
    #expect(button.resolvedTitle() == "Open")
    #expect(button.image == .icon(.search))
}

@Test("Concord strings expose common Action Group titles")
func concordStringsExposeActionGroupTitles() {
    #expect(ConcordString.special == "Special")
    #expect(ConcordString.links == "Links")
}


@Test("FAQ feature data wraps explicitly created question sections")
func faqFeatureDataWrapsQuestionSections() {
    let question = ConcordQAData(
        question: "What is ConcordUI?",
        answer: "A cross-platform Swift UI framework."
    )
    let section = ConcordQAListData(
        title: "General",
        questions: [question]
    )
    let data = ConcordFAQFeatureData(sections: [section])

    #expect(data.sections.count == 1)
    #expect(data.sections[0].title == "General")
    #expect(data.sections[0].questions[0].question == "What is ConcordUI?")
}

@Test("FAQ feature data decodes one JSON document")
func faqFeatureDataDecodesJSONDocument() throws {
    let json = """
    {
      "sections": [
        {
          "title": "General",
          "questions": [
            {
              "question": "Does this decode?",
              "answer": "Yes."
            }
          ]
        }
      ]
    }
    """

    let data = try ConcordFAQFeatureData(json: json)

    #expect(data.sections.count == 1)
    #expect(data.sections[0].questions.count == 1)
    #expect(data.sections[0].questions[0].answer == "Yes.")
    #expect(data.sections[0].questions[0].access.isEmpty)
}

@Test("Standard FAQ accepts complete feature data")
func standardFAQAcceptsFeatureData() {
    let application = ConcordApplication(platform: TestPlatform())
    let data = ConcordFAQFeatureData(
        sections: [
            ConcordQAListData(
                title: "",
                questions: [
                    ConcordQAData(question: "Question?", answer: "Answer.")
                ]
            )
        ]
    )

    let configured = application.useStandardFAQFeature(data: data)

    #expect(configured === application)
    #expect(application.faqFeature != nil)
}


@Test("All Special button uses application actions and requested flavor")
func allSpecialButtonUsesApplicationActions() {
    var invoked = false
    let application = ConcordApplication(platform: TestPlatform())
        .createSpecialItem(
            action: ConcordTitleAction("Reset") {
                invoked = true
            }
        )

    guard let button = application.concordAllSpecialButton(
        title: "Utilities",
        flavor: .stack,
        image: .icon(.warning)
    ) as? ConcordTitleActionElement else {
        Issue.record("Expected a Special title-action element")
        return
    }

    #expect(button.flavor == .stack)
    #expect(button.edge == 0)
    #expect(button.label == "Utilities")
    #expect(button.image == .icon(.warning))
    #expect(button.actionTitle(at: 0) == "Reset")
    button.activateAction(at: 0)
    #expect(invoked)
}


@Test("Text-icon button stores title before semantic icon")
func textIconButtonConfiguration() {
    let button = ConcordButton(
        "More Information",
        flavor: .textIcon,
        icon: .information
    ) {}

    #expect(button.flavor == .textIcon)
    #expect(button.title == "More Information")
    #expect(button.icon == .information)
    #expect(button.accessibilityText == "More Information")
}

@Test("Feature button title overrides configuration and supplies accessibility")
func featureButtonTitleOverride() {
    let application = ConcordApplication(platform: TestPlatform())
    application.aboutFeature = ConcordFeatureConfig(title: "Configured About")

    let button = application.concordAboutFeatureButton(
        title: "Application Details"
    )

    #expect(button.flavor == .textIcon)
    #expect(button.title == "Application Details")
    #expect(button.accessibilityText == "Application Details")
}


@Test("Help feature supports action, presentation, and feature button")
func helpFeatureSupportsAllInvocationPaths() {
    let actionApplication = ConcordApplication(platform: TestPlatform())
    var invoked = false
    actionApplication.helpFeature = ConcordFeatureConfig(
        title: "Help",
        action: { invoked = true }
    )

    let button = actionApplication.concordHelpFeatureButton(
        title: "Assistance"
    )
    #expect(button.flavor == .textIcon)
    #expect(button.title == "Assistance")
    #expect(button.accessibilityText == "Assistance")
    button.activate()
    #expect(invoked)

    let presentationApplication = ConcordApplication(platform: TestPlatform())
    presentationApplication.helpFeature = ConcordFeatureConfig(
        presentation: {
            ConcordPresentation {
                ConcordText(ConcordString.tba)
            }
        },
        preferredWindowSize: (width: 480, height: 320),
        dismissAble: true
    )

    presentationApplication.showHelpFeature()

    let venue = presentationApplication.secondaryVenue(id: ConcordVenueID.help)
    #expect(venue != nil)
    #expect(venue?.config.name == ConcordString.helpTitle(presentationApplication.platform.appName))
    #expect(venue?.currentPresentation != nil)
    #expect(venue?.config.dismissAble == true)
}

@Test("Settings feature supports action, presentation, and feature button")
func settingsFeatureSupportsAllInvocationPaths() {
    let actionApplication = ConcordApplication(platform: TestPlatform())
    var invoked = false
    actionApplication.settingsFeature = ConcordFeatureConfig(
        title: "Preferences",
        action: { invoked = true }
    )

    let button = actionApplication.concordSettingsFeatureButton(
        title: "Options"
    )
    #expect(button.flavor == .textIcon)
    #expect(button.title == "Options")
    #expect(button.accessibilityText == "Options")
    button.activate()
    #expect(invoked)

    let presentationApplication = ConcordApplication(platform: TestPlatform())
    presentationApplication.settingsFeature = ConcordFeatureConfig(
        presentation: {
            ConcordPresentation {
                ConcordText(ConcordString.tba)
            }
        },
        preferredWindowSize: (width: 480, height: 320),
        dismissAble: true
    )

    presentationApplication.showSettingsFeature()

    let venue = presentationApplication.secondaryVenue(id: ConcordVenueID.settings)
    #expect(venue != nil)
    #expect(venue?.config.name == ConcordString.settings)
    #expect(venue?.currentPresentation != nil)
    #expect(venue?.config.dismissAble == true)
}

@Test("All Settings popup places the feature before added actions")
func allSettingsPopupIncludesFeatureFirst() {
    let application = ConcordApplication(platform: TestPlatform())
    application.settingsFeature = ConcordFeatureConfig(
        title: "Preferences",
        action: {}
    )
    application.addSettingAction(ConcordTitleAction("Website") {})

    guard let popup = application.concordAllSettingButton()
        as? ConcordTitleActionElement else {
        Issue.record("Expected a Settings title-action popup")
        return
    }

    #expect(popup.flavor == .popup)
    #expect(popup.actionTitle(at: 0) == "Preferences")
    #expect(popup.actionTitle(at: 1) == "Website")
}

@Test("Concord strings include TBA")
func concordStringsIncludeTBA() {
    #expect(ConcordString.tba == "TBA")
}


@Test("Standard feature buttons use distinct semantic icons")
func standardFeatureButtonsUseDistinctIcons() {
    let application = ConcordApplication(platform: TestPlatform())

    #expect(application.concordAboutFeatureButton().icon == .information)
    #expect(application.concordWelcomeFeatureButton().icon == .welcome)
    #expect(application.concordGetStartedFeatureButton().icon == .getStarted)
    #expect(application.concordWhatsNewFeatureButton().icon == .whatsNew)
    #expect(application.concordFAQFeatureButton().icon == .faq)
    #expect(application.concordHelpFeatureButton().icon == .help)
    #expect(application.concordSettingsFeatureButton().icon == .settings)
}

@Test("Feature buttons accept caller-selected flavors")
func featureButtonsAcceptCallerSelectedFlavors() {
    let application = ConcordApplication(platform: TestPlatform())

    #expect(application.concordAboutFeatureButton(flavor: .icon).flavor == .icon)
    #expect(application.concordWelcomeFeatureButton(flavor: .roundedRectangle).flavor == .roundedRectangle)
    #expect(application.concordGetStartedFeatureButton(flavor: .text).flavor == .text)
    #expect(application.concordWhatsNewFeatureButton(flavor: .textIcon).flavor == .textIcon)
    #expect(application.concordFAQFeatureButton(flavor: .icon).flavor == .icon)
    #expect(application.concordHelpFeatureButton(flavor: .roundedRectangle).flavor == .roundedRectangle)
    #expect(application.concordSettingsFeatureButton(flavor: .textIcon).flavor == .textIcon)
}
