//
//  ConcordHelpFeaturesButton.swift
//  ConcordUI
//
//  Platform-neutral controls for Help and Settings menu actions.
//

private enum ConcordHelpEntry {
    case help
    case welcome
    case getStarted
    case whatsNew
    case faq
    case action(Int)
}

public extension ConcordApplication {
    /// Creates a control containing all configured Help features and actions.
    ///
    /// The order matches the macOS Help menu: Help, Welcome, Get Started,
    /// What's New, FAQ, and then developer-added Help actions. No entries returns a blank element.
    func concordAllHelpButton(
        title: String? = nil,
        flavor: ConcordTitleActionFlavor = .popup
    ) -> ConcordElement {
        var entries: [ConcordHelpEntry] = []

        if helpFeature != nil {
            entries.append(.help)
        }
        if welcomeFeature != nil {
            entries.append(.welcome)
        }
        if getStartedFeature != nil {
            entries.append(.getStarted)
        }
        if whatsNewFeature != nil {
            entries.append(.whatsNew)
        }
        if faqFeature != nil {
            entries.append(.faq)
        }
        entries.append(contentsOf: helpActions.indices.map(ConcordHelpEntry.action))

        guard !entries.isEmpty else {
            return ConcordBlankElement()
        }

        let actions = entries.map { helpAction(for: $0, application: self) }
        let resolvedTitle = title
            ?? (actions.count == 1 ? actions[0].title : ConcordString.help)
        return ConcordTitleActionElement(
            flavor,
            actions: actions,
            label: resolvedTitle,
            image: .icon(.information)
        )
        .edge(0)
    }

    /// Creates a control containing the Settings feature and developer-added actions.
    ///
    /// No configured feature or actions returns a blank element.
    func concordAllSettingButton(
        title: String? = nil,
        flavor: ConcordTitleActionFlavor = .popup
    ) -> ConcordElement {
        var actions: [ConcordTitleAction] = []

        if let settingsFeature {
            actions.append(
                ConcordTitleAction(
                    settingsFeature.title ?? ConcordString.settings
                ) { [weak self] in
                    self?.showSettingsFeature()
                }
            )
        }
        actions.append(contentsOf: settingActions)

        guard !actions.isEmpty else {
            return ConcordBlankElement()
        }

        let resolvedTitle = title
            ?? (actions.count == 1 ? actions[0].title : ConcordString.settings)
        return ConcordTitleActionElement(
            flavor,
            actions: actions,
            label: resolvedTitle,
            image: .icon(.settings)
        )
        .edge(0)
    }
}

private func helpAction(
    for entry: ConcordHelpEntry,
    application: ConcordApplication
) -> ConcordTitleAction {
    switch entry {
    case .help:
        return ConcordTitleAction(
            application.helpFeature?.title ?? ConcordString.helpTitle(application.platform.appName)
        ) { [weak application] in
            application?.showHelpFeature()
        }
    case .welcome:
        return ConcordTitleAction(
            application.welcomeFeature?.title
                ?? ConcordString.welcomeTitle(application.platform.appName)
        ) { [weak application] in
            application?.showWelcomeFeature()
        }
    case .getStarted:
        return ConcordTitleAction(
            application.getStartedFeature?.title ?? ConcordString.getStarted
        ) { [weak application] in
            application?.showGetStartedFeature()
        }
    case .whatsNew:
        return ConcordTitleAction(
            application.whatsNewFeature?.title ?? ConcordString.whatsNew
        ) { [weak application] in
            application?.showWhatsNewFeature()
        }
    case .faq:
        return ConcordTitleAction(
            application.faqFeature?.title
                ?? ConcordString.faqTitle(application.platform.appName)
        ) { [weak application] in
            application?.showFAQFeature()
        }
    case .action(let index):
        return application.helpActions[index]
    }
}
