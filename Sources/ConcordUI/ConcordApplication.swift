//
//  ConcordApplication.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/15/26.
//

import Foundation

public enum ConcordRequiredIndicator: Sendable, Equatable {
    case none
    case redAsterisk
    case requiredText
}

public enum ConcordInvalidIndicator: Sendable, Equatable {
    case none
    case errorText
    case redBorder
    case redBorderAndErrorText
}

/// Standard locations for application-level functionality.
///
/// About, Settings, and Welcome are singular. Help and application-specific
/// functionality may contain multiple entries distinguished by position.
public enum ConcordApplicationFunctionalityType: Sendable, Hashable {
    case about
    case settings
    case welcome
    case help
    case application
}

/// A deferred application-level Presentation together with the metadata needed
/// for platform-appropriate menus, title-bar controls, or mobile pull-downs.
public struct ConcordApplicationFunctionality {
    public let type: ConcordApplicationFunctionalityType
    public let position: Int
    public let title: String?
    private let elementBuilder: ConcordElementBuilder

    internal init(
        type: ConcordApplicationFunctionalityType,
        position: Int,
        title: String?,
        elementBuilder: @escaping ConcordElementBuilder
    ) {
        self.type = type
        self.position = position
        self.title = title
        self.elementBuilder = elementBuilder
    }

    /// Builds the root element only when the functionality is presented.
    public func buildElements() -> ConcordElement {
        elementBuilder()
    }
}

open class ConcordApplication {
    public let platform: any ConcordPlatform

    /// Reusable materials available to vector and other drawing commands.
    public let materialRegistry = ConcordMaterialRegistry.shared

    /// The application's singleton primary hosting context.
    public let mainVenue: ConcordMainVenue

    /// Non-modal hosting contexts created by the Application in addition to Main Venue.
    public private(set) var secondaryVenues: [ConcordSecondaryVenue] = []

    /// Compatibility view retained while callers migrate to Secondary Venue terminology.
    @available(*, deprecated, renamed: "secondaryVenues")
    public var auxiliaryVenues: [ConcordSecondaryVenue] { secondaryVenues }

    /// Application-level data. The Main Venue inherits this value by default.
    public var currentData: (any ConcordDataProtocol)? {
        didSet { mainVenue.currentData = currentData }
    }

    /// True only for the first application launch recorded by ConcordUI.
    public private(set) var isFirstTimeLaunch: Bool

    /// True when this is the first recorded launch of the current user-facing version.
    public private(set) var isFirstTimeNewVersion: Bool

    /// Total number of launches recorded by ConcordUI, including the current launch.
    public private(set) var numberLaunches: Int

    public var displayInformation: ConcordDisplayInformation {
        didSet {
            mainVenue.refreshDisplayInformation()
            for venue in secondaryVenues {
                venue.refreshDisplayInformation()
            }
        }
    }

    public var requiredIndicator: ConcordRequiredIndicator {
        get { displayInformation.requiredIndicator }
        set { displayInformation = ConcordDisplayInformation(theme: displayInformation.theme, requiredIndicator: newValue, invalidIndicator: displayInformation.invalidIndicator, elementFont: displayInformation.elementFont, elementFontSize: displayInformation.elementFontSize) }
    }
    public var invalidIndicator: ConcordInvalidIndicator {
        get { displayInformation.invalidIndicator }
        set { displayInformation = ConcordDisplayInformation(theme: displayInformation.theme, requiredIndicator: displayInformation.requiredIndicator, invalidIndicator: newValue, elementFont: displayInformation.elementFont, elementFontSize: displayInformation.elementFontSize) }
    }
    public var theme: ConcordTheme {
        get { displayInformation.theme }
        set { displayInformation = ConcordDisplayInformation(theme: newValue, requiredIndicator: displayInformation.requiredIndicator, invalidIndicator: displayInformation.invalidIndicator, elementFont: displayInformation.elementFont, elementFontSize: displayInformation.elementFontSize) }
    }
    public var elementFont: ConcordFont {
        get { displayInformation.elementFont }
        set { displayInformation = ConcordDisplayInformation(theme: displayInformation.theme, requiredIndicator: displayInformation.requiredIndicator, invalidIndicator: displayInformation.invalidIndicator, elementFont: newValue, elementFontSize: displayInformation.elementFontSize) }
    }
    public var elementFontSize: Double {
        get { displayInformation.elementFontSize }
        set { displayInformation = ConcordDisplayInformation(theme: displayInformation.theme, requiredIndicator: displayInformation.requiredIndicator, invalidIndicator: displayInformation.invalidIndicator, elementFont: displayInformation.elementFont, elementFontSize: newValue) }
    }

    /// Convenience view of the Presentation currently occupying the Main Venue.
    public var currentPresentation: ConcordPresentation? { mainVenue.currentPresentation }

    /// Optional app-provided About feature. Nil leaves About to platform behavior.
    public var aboutFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided Settings feature. Nil leaves Settings to platform behavior.
    public var settingsFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided Help feature. Nil leaves Help to platform behavior.
    public var helpFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided Welcome feature.
    public var welcomeFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided Get Started feature.
    public var getStartedFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided What's New feature.
    public var whatsNewFeature: ConcordFeatureConfig? = nil

    /// Optional app-provided FAQ feature.
    public var faqFeature: ConcordFeatureConfig? = nil

    /// Additional titled actions displayed after the standard Help features.
    public private(set) var helpActions: [ConcordTitleAction] = []

    /// Titled actions displayed in the application's Settings collection.
    public private(set) var settingActions: [ConcordTitleAction] = []

    /// Registered general Action Groups in creation order. The predefined
    /// Special group is stored separately so it can always be displayed last.
    private var registeredActionGroups: [ConcordActionGroup] = []

    /// The predefined Special group, displayed after all general Action Groups.
    private let specialActionGroup = ConcordActionGroup(
        tag: ConcordActionGroup.specialTag,
        title: ConcordString.special
    )

    public var action: ConcordActionClosure?

    /// Optional desktop menu or mobile pull-down title for application-specific functionality.
    public private(set) var applicationMenuTitle: String?

    private var applicationFunctionalities: [ConcordApplicationFunctionalityType: [Int: ConcordApplicationFunctionality]] = [:]

    private enum LaunchStorageKey {
        static let numberLaunches = "concordui.application.numberLaunches"
        static let lastVersion = "concordui.application.lastVersion"
    }

    private enum StandardStartupFeature {
        case welcome
        case getStarted
        case whatsNew
    }

    private var pendingStandardStartupFeature: StandardStartupFeature?

    public init(
        platform: any ConcordPlatform,
        currentData: (any ConcordDataProtocol)? = nil,
        theme: ConcordTheme = ConcordTheme(),
        requiredIndicator: ConcordRequiredIndicator = .redAsterisk,
        invalidIndicator: ConcordInvalidIndicator = .errorText,
        elementFont: ConcordFont = .system,
        elementFontSize: Double = 17
    ) {
        ConcordMaterial.registerMaterials()
        self.platform = platform
        self.currentData = currentData
        self.displayInformation = ConcordDisplayInformation(
            theme: theme,
            requiredIndicator: requiredIndicator,
            invalidIndicator: invalidIndicator,
            elementFont: elementFont,
            elementFontSize: elementFontSize
        )
        self.mainVenue = ConcordMainVenue(
            name: platform.appName,
            currentData: currentData
        )
        self.pendingStandardStartupFeature = nil

        let previousLaunchCount = platform.permanentIntegerRetrieve(key: LaunchStorageKey.numberLaunches) ?? 0
        self.numberLaunches = previousLaunchCount + 1
        self.isFirstTimeLaunch = previousLaunchCount == 0

        let currentVersion = platform.appVersion
        let previousVersion = platform.permanentStringRetrieve(key: LaunchStorageKey.lastVersion)
        self.isFirstTimeNewVersion = previousVersion != currentVersion

        mainVenue.attach(to: self)

        _ = platform.permanentIntegerStore(key: LaunchStorageKey.numberLaunches, value: numberLaunches)
        _ = platform.permanentStringStore(key: LaunchStorageKey.lastVersion, value: currentVersion)
    }

    /// Called by the platform host when the application is ready to construct its UI.
    open func startApplication() {}

    @discardableResult
    public func registerMaterial(
        key: String,
        material: ConcordMaterial
    ) -> Self {
        materialRegistry.register(key: key, material: material)
        return self
    }

    public func resolveMaterial(_ material: ConcordMaterial) -> ConcordMaterial {
        materialRegistry.resolve(material)
    }

    /// Adds developer-controlled behavior to the Help menu and combined Help button.
    @discardableResult
    public func addHelpAction(_ action: ConcordTitleAction) -> Self {
        helpActions.append(action)
        return self
    }

    /// Adds a URL or bundled-file destination to the Help actions.
    @discardableResult
    public func addHelpAccess(_ access: ConcordAccessData) -> Self {
        addHelpAction(
            ConcordTitleAction(access.title) { [weak self] in
                guard let self else { return }
                access.openAccess(using: self)
            }
        )
    }

    /// Adds developer-controlled behavior to the Settings menu and combined Settings button.
    @discardableResult
    public func addSettingAction(_ action: ConcordTitleAction) -> Self {
        settingActions.append(action)
        return self
    }

    /// Adds a URL or bundled-file destination to the Settings actions.
    @discardableResult
    public func addSettingAccess(_ access: ConcordAccessData) -> Self {
        addSettingAction(
            ConcordTitleAction(access.title) { [weak self] in
                guard let self else { return }
                access.openAccess(using: self)
            }
        )
    }

    /// Registers an application Action Group.
    @discardableResult
    public func createActionGroup(tag: String, title: String) -> Self {
        precondition(tag != ConcordActionGroup.specialTag,
                     "\(ConcordActionGroup.specialTag) is reserved for the Special group.")
        precondition(actionGroup(tag: tag) == nil,
                     "An Action Group with tag '\(tag)' is already registered.")
        registeredActionGroups.append(ConcordActionGroup(tag: tag, title: title))
        return self
    }

    /// Adds either an access destination or a direct action to a registered group.
    @discardableResult
    public func createActionGroupItem(
        groupTag: String,
        access: ConcordAccessData? = nil,
        action: ConcordTitleAction? = nil
    ) -> Self {
        precondition((access == nil) != (action == nil),
                     "An Action Group item requires exactly one access or action.")
        guard let group = actionGroup(tag: groupTag) else {
            preconditionFailure("No Action Group is registered with tag '\(groupTag)'.")
        }

        if let action {
            group.add(action)
        } else if let access {
            group.add(
                ConcordTitleAction(access.title) { [weak self] in
                    guard let self else { return }
                    access.openAccess(using: self)
                }
            )
        }
        return self
    }

    /// Adds an item to the predefined Special Action Group.
    @discardableResult
    public func createSpecialItem(
        access: ConcordAccessData? = nil,
        action: ConcordTitleAction? = nil
    ) -> Self {
        createActionGroupItem(
            groupTag: ConcordActionGroup.specialTag,
            access: access,
            action: action
        )
    }

    /// Returns a registered Action Group, including the predefined Special group.
    public func actionGroup(tag: String) -> ConcordActionGroup? {
        if tag == ConcordActionGroup.specialTag {
            return specialActionGroup
        }
        return registeredActionGroups.first { $0.tag == tag }
    }

    /// Nonempty Action Groups in menu order, with Special always last.
    public var displayedActionGroups: [ConcordActionGroup] {
        var groups = registeredActionGroups.filter { !$0.actions.isEmpty }
        if !specialActionGroup.actions.isEmpty {
            groups.append(specialActionGroup)
        }
        return groups
    }

    /// Performs ConcordUI's standard application startup.
    ///
    /// Home is handed to the platform first. The platform host then calls
    /// completeStandardAppStart() after its root view appears so any startup
    /// feature is presented over the established Home Presentation.
    public func standardAppStart() {
        displayHome()

        if isFirstTimeLaunch, welcomeFeature != nil {
            pendingStandardStartupFeature = .welcome
        } else if isFirstTimeLaunch, getStartedFeature != nil {
            pendingStandardStartupFeature = .getStarted
        } else if isFirstTimeNewVersion, whatsNewFeature != nil {
            pendingStandardStartupFeature = .whatsNew
        } else {
            pendingStandardStartupFeature = nil
        }
    }

    /// Completes a pending standard startup after the platform has presented Home.
    ///
    /// Platform hosts call this lifecycle hook; repeated calls have no effect.
    public func completeStandardAppStart() {
        let feature = pendingStandardStartupFeature
        pendingStandardStartupFeature = nil

        switch feature {
        case .welcome:
            showWelcomeFeature(firstTime: true)
        case .getStarted:
            showGetStartedFeature()
        case .whatsNew:
            showWhatsNewFeature()
        case nil:
            break
        }
    }

    /// Clears the recorded launch count so the next launch is treated as the
    /// application's first launch.
    @discardableResult
    public func resetFirstTimeLaunch() -> Bool {
        platform.removePersistentValue(forKey: LaunchStorageKey.numberLaunches)
    }

    /// Clears the recorded app version so the next launch is treated as the
    /// first launch of that version.
    @discardableResult
    public func resetFirstTimeNewVersion() -> Bool {
        platform.removePersistentValue(forKey: LaunchStorageKey.lastVersion)
    }

    /// Compatibility entry point retained for applications overriding the older lifecycle.
    @available(*, deprecated, message: "Override startApplication() instead")
    open func start() {
        startApplication()
    }

    /// Displays a Presentation in the application's Main Venue.
    public func displayMainPresentation(
        _ presentation: ConcordPresentation,
        data: (any ConcordDataProtocol)? = nil
    ) {
        mainVenue.displayPresentation(presentation, data: data)
    }

    /// Looks up a Secondary Venue by its stable identifier.
    public func secondaryVenue(id: String) -> ConcordSecondaryVenue? {
        secondaryVenues.first { $0.id == id }
    }

    @discardableResult
    public func createSecondaryVenue(
        id: String,
        config: ConcordVenueConfig,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) -> ConcordSecondaryVenue {
        precondition(!id.isEmpty, "ConcordUI Venue identifiers must not be empty.")
        precondition(!ConcordVenueID.isReserved(id), "Venue identifiers beginning with 'concordui.' or 'concordui-' are reserved by ConcordUI.")
        precondition(secondaryVenue(id: id) == nil, "A Secondary Venue with identifier '\(id)' already exists.")
        precondition(config.kind == .secondary, "createSecondaryVenue requires a .secondary ConcordVenueConfig.")

        return createSecondaryVenueInternal(
            id: id,
            config: config,
            currentData: currentData,
            displayOptions: displayOptions
        )
    }

    /// Framework-only creation path for reserved ConcordUI Secondary Venues such as
    /// About, Settings, What's New, and Help.
    @discardableResult
    internal func createSystemSecondaryVenue(
        id: String,
        config: ConcordVenueConfig,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) -> ConcordSecondaryVenue {
        precondition(ConcordVenueID.isReserved(id), "System Venue identifiers must begin with 'concordui.' or 'concordui-'.")
        precondition(id != ConcordVenueID.main, "concordui.main is reserved for the Main Venue.")
        precondition(secondaryVenue(id: id) == nil, "A Secondary Venue with identifier '\(id)' already exists.")
        precondition(config.kind == .secondary, "createSystemSecondaryVenue requires a .secondary ConcordVenueConfig.")

        return createSecondaryVenueInternal(
            id: id,
            config: config,
            currentData: currentData,
            displayOptions: displayOptions
        )
    }

    private func createSecondaryVenueInternal(
        id: String,
        config: ConcordVenueConfig,
        currentData: (any ConcordDataProtocol)?,
        displayOptions: ConcordDisplayOptions?
    ) -> ConcordSecondaryVenue {
        let venue = ConcordSecondaryVenue(
            id: id,
            application: self,
            config: config,
            currentData: currentData ?? self.currentData,
            displayOptions: displayOptions
        )
        secondaryVenues.append(venue)
        return venue
    }

    /// Removes a Secondary Venue and dismisses its native realization first.
    ///
    /// On desktop this closes the Venue's native window. On mobile/tablet the platform
    /// restores the Main Venue Presentation when the removed Secondary Venue is visible.
    public func removeSecondaryVenue(_ venue: ConcordSecondaryVenue) {
        venue.dismissOwnedModalVenues()
        if let lifecycle = platform as? any ConcordVenuePlatformLifecycle {
            lifecycle.dismissVenue(venue)
        } else if let mainPresentation = mainVenue.currentPresentation {
            platform.displayPresentation(mainPresentation, in: mainVenue)
        }
        venue.clearPresentation()
        secondaryVenues.removeAll { $0 === venue }
    }

    /// Removes a Secondary Venue by identifier when it exists.
    public func removeSecondaryVenue(id: String) {
        guard let venue = secondaryVenue(id: id) else { return }
        removeSecondaryVenue(venue)
    }

    @available(*, deprecated, message: "Use createSecondaryVenue(id:config:currentData:displayOptions:)")
    @discardableResult
    public func createAuxiliaryVenue(
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) -> ConcordSecondaryVenue {
        createSecondaryVenue(
            id: "legacy.auxiliary.\(UUID().uuidString.lowercased())",
            config: ConcordVenueConfig(kind: .secondary),
            currentData: currentData,
            displayOptions: displayOptions
        )
    }

    @available(*, deprecated, renamed: "removeSecondaryVenue")
    public func removeAuxiliaryVenue(_ venue: ConcordSecondaryVenue) {
        removeSecondaryVenue(venue)
    }

    // MARK: - Home

    /// Convenience registration of the Main Venue's Home Presentation.
    public func registerHome(builder: @escaping ConcordPresentationBuilder) {
        mainVenue.registerHome(builder: builder)
    }

    /// Convenience navigation to the Main Venue's registered Home Presentation.
    public func displayHome() {
        _ = mainVenue.displayHome()
    }

    /// Invokes an app-managed About action or displays the configured About Presentation.
    /// Without a configured feature, platform About behavior is left unchanged.
    public func showAboutFeature() {
        guard let aboutFeature else { return }
        let config = ConcordFeatureConfig(
            title: aboutFeature.title ?? ConcordString.aboutTitle(platform.appName),
            action: aboutFeature.action,
            presentation: aboutFeature.presentation,
            preferredWindowSize: aboutFeature.preferredWindowSize,
            dismissAble: aboutFeature.dismissAble,
            closeLabel: aboutFeature.closeLabel
        )
        showFeature(key: ConcordVenueID.about, config: config)
    }

    /// Invokes an app-managed Settings action or displays its configured Presentation.
    /// Without a configured feature, platform Settings behavior is left unchanged.
    public func showSettingsFeature() {
        guard let settingsFeature else { return }
        let config = ConcordFeatureConfig(
            title: settingsFeature.title ?? ConcordString.settings,
            action: settingsFeature.action,
            presentation: settingsFeature.presentation,
            preferredWindowSize: settingsFeature.preferredWindowSize,
            dismissAble: settingsFeature.dismissAble,
            closeLabel: settingsFeature.closeLabel
        )
        showFeature(key: ConcordVenueID.settings, config: config)
    }

    /// Invokes an app-managed Help action or displays its configured Presentation.
    /// Without a configured feature, platform Help behavior is left unchanged.
    public func showHelpFeature() {
        guard let helpFeature else { return }
        let config = ConcordFeatureConfig(
            title: helpFeature.title ?? ConcordString.helpTitle(platform.appName),
            action: helpFeature.action,
            presentation: helpFeature.presentation,
            preferredWindowSize: helpFeature.preferredWindowSize,
            dismissAble: helpFeature.dismissAble,
            closeLabel: helpFeature.closeLabel
        )
        showFeature(key: ConcordVenueID.help, config: config)
    }

    /// Invokes an app-managed Welcome action or displays its configured Presentation.
    ///
    /// When invoked for the application's first launch, a configured Get Started
    /// feature is offered through a centered Continue button in the Work Stack footer.
    public func showWelcomeFeature(firstTime: Bool = false) {
        guard let welcomeFeature else { return }
        guard firstTime,
              getStartedFeature != nil,
              let buildPresentation = welcomeFeature.presentation else {
            showFeature(key: ConcordVenueID.welcome, config: welcomeFeature)
            return
        }

        let config = ConcordFeatureConfig(
            title: welcomeFeature.title,
            action: welcomeFeature.action,
            presentation: { [weak self] in
                let presentation = buildPresentation()
                guard let self else { return presentation }

                let continueButton = ConcordButton(ConcordString.continueText) { [weak self] in
                    guard let self else { return }
                    self.secondaryVenue(id: ConcordVenueID.welcome)?.closeVenue()
                    self.showGetStartedFeature()
                }
                presentation.appendElementToWorkStackBottomAfterBuild(
                    continueButton,
                    centered: true
                )
                return presentation
            },
            preferredWindowSize: welcomeFeature.preferredWindowSize,
            dismissAble: welcomeFeature.dismissAble,
            closeLabel: welcomeFeature.closeLabel
        )
        showFeature(key: ConcordVenueID.welcome, config: config)
    }

    /// Invokes an app-managed Get Started action or displays its configured Presentation.
    public func showGetStartedFeature() {
        guard let getStartedFeature else { return }
        showFeature(key: ConcordVenueID.getStarted, config: getStartedFeature)
    }

    /// Invokes an app-managed What's New action or displays its configured Presentation.
    public func showWhatsNewFeature() {
        guard let whatsNewFeature else { return }
        showFeature(key: ConcordVenueID.whatsNew, config: whatsNewFeature)
    }

    /// Invokes an app-managed FAQ action or displays its configured Presentation.
    public func showFAQFeature() {
        guard let faqFeature else { return }
        showFeature(key: ConcordVenueID.faq, config: faqFeature)
    }

    /// Invokes a configured application action or displays its Presentation in a
    /// reusable, framework-managed Secondary Venue identified by `key`.
    public func showFeature(key: String, config: ConcordFeatureConfig) {
        precondition(ConcordVenueID.isReserved(key),
                     "Feature keys must use a reserved ConcordUI Venue identifier.")
        precondition(key != ConcordVenueID.main,
                     "The Main Venue identifier cannot be used as a feature key.")

        if let action = config.action {
            action()
            return
        }

        guard let buildPresentation = config.presentation else { return }
        let title = config.title ?? platform.appName
        let venue: ConcordSecondaryVenue
        if let existing = secondaryVenue(id: key) {
            venue = existing
            venue.venue(name: title)
        } else {
            let size = config.preferredWindowSize.map {
                ConcordVenueSize(Double($0.width), Double($0.height))
            }
            venue = createSystemSecondaryVenue(
                id: key,
                config: ConcordVenueConfig(
                    kind: .secondary,
                    name: title,
                    closable: true,
                    dismissAble: config.dismissAble,
                    closeLabel: config.closeLabel,
                    initialSize: size,
                    minSize: size,
                    maxSize: size
                )
            )
        }
        if let size = config.preferredWindowSize {
            venue.size(Double(size.width), Double(size.height))
            venue.minSize(Double(size.width), Double(size.height))
            venue.maxSize(Double(size.width), Double(size.height))
        }
        venue.displayPresentation(buildPresentation())
    }

    // MARK: - Application Functionality

    public func applicationFunctionalities(
        for type: ConcordApplicationFunctionalityType
    ) -> [ConcordApplicationFunctionality] {
        guard let entries = applicationFunctionalities[type] else { return [] }
        return entries.values.sorted { $0.position < $1.position }
    }

    public func applicationFunctionality(
        _ type: ConcordApplicationFunctionalityType,
        position: Int = 1
    ) -> ConcordApplicationFunctionality? {
        applicationFunctionalities[type]?[position]
    }

    @discardableResult
    public func aboutPresentation(
        title: String? = nil,
        _ content: @escaping ConcordElementBuilder
    ) -> Self {
        setApplicationFunctionality(.about, position: 1, title: title, content: content)
        return self
    }

    @discardableResult
    public func settingsPresentation(
        title: String? = nil,
        _ content: @escaping ConcordElementBuilder
    ) -> Self {
        setApplicationFunctionality(.settings, position: 1, title: title, content: content)
        return self
    }

    @discardableResult
    public func welcomePresentation(
        title: String? = nil,
        _ content: @escaping ConcordElementBuilder
    ) -> Self {
        setApplicationFunctionality(.welcome, position: 1, title: title, content: content)
        return self
    }

    @discardableResult
    public func helpPresentation(
        position: Int = 1,
        title: String? = nil,
        _ content: @escaping ConcordElementBuilder
    ) -> Self {
        precondition(position > 0, "Help functionality position must be greater than zero.")
        setApplicationFunctionality(.help, position: position, title: title, content: content)
        return self
    }

    @discardableResult
    public func applicationPresentation(
        position: Int,
        title: String? = nil,
        _ content: @escaping ConcordElementBuilder
    ) -> Self {
        precondition(position > 0, "Application functionality position must be greater than zero.")
        setApplicationFunctionality(.application, position: position, title: title, content: content)
        return self
    }

    @discardableResult
    public func applicationMenu(title: String) -> Self {
        applicationMenuTitle = title
        return self
    }

    private func setApplicationFunctionality(
        _ type: ConcordApplicationFunctionalityType,
        position: Int,
        title: String?,
        content: @escaping ConcordElementBuilder
    ) {
        var entries = applicationFunctionalities[type] ?? [:]
        entries[position] = ConcordApplicationFunctionality(
            type: type,
            position: position,
            title: title,
            elementBuilder: content
        )
        applicationFunctionalities[type] = entries
    }

    internal func dispatchApplicationAction(_ event: ConcordActionEvent) {
        action?(event)
    }
}
