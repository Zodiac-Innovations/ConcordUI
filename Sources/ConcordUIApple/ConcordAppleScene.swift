import ConcordUI
import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Default native SwiftUI scene for a ConcordUI application.
///
/// The Main Venue is hosted by the platform's primary scene. On macOS its Venue
/// configuration is applied to the native window. iOS preserves the same Venue
/// configuration and semantics but ignores desktop-only window values.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct ConcordAppleScene: Scene {
    private let platform: ConcordApplePlatform
    private let application: ConcordApplication?

    #if os(macOS)
    private var initialWindowSize: ConcordVenueSize {
        application?.mainVenue.config.initialSize ?? ConcordVenueSize(640, 480)
    }
    #endif

    public init(platform: ConcordApplePlatform, application: ConcordApplication? = nil) {
        self.platform = platform
        self.application = application
    }

    public var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ConcordAppleConfiguredRootView(platform: platform, application: application)
        }
        .defaultSize(
            width: CGFloat(initialWindowSize.horizontal),
            height: CGFloat(initialWindowSize.vertical)
        )
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(ConcordString.pageSetup) {}
                    .disabled(true)
                Button(ConcordString.print) {}
                    .keyboardShortcut("p", modifiers: .command)
                    .disabled(true)
            }
            if let application = application ?? platform.currentVenue?.application {
                if let aboutFeature = application.aboutFeature {
                    CommandGroup(replacing: .appInfo) {
                        Button(aboutFeature.title ?? ConcordString.aboutTitle(platform.appName)) {
                            application.showAboutFeature()
                        }
                    }
                }
                if application.settingsFeature != nil
                    || !application.settingActions.isEmpty {
                    CommandGroup(replacing: .appSettings) {
                        if let settingsFeature = application.settingsFeature {
                            Button(settingsFeature.title ?? ConcordString.settings) {
                                application.showSettingsFeature()
                            }
                        }
                        ForEach(Array(application.settingActions.enumerated()), id: \.offset) { _, action in
                            Button(action.title) {
                                action.invoke()
                            }
                        }
                    }
                }
                if application.helpFeature != nil
                    || application.welcomeFeature != nil
                    || application.getStartedFeature != nil
                    || application.whatsNewFeature != nil
                    || application.faqFeature != nil
                    || !application.helpActions.isEmpty {
                    CommandGroup(replacing: .help) {
                        if let helpFeature = application.helpFeature {
                            Button(helpFeature.title ?? ConcordString.helpTitle(platform.appName)) {
                                application.showHelpFeature()
                            }
                        }
                        if let welcomeFeature = application.welcomeFeature {
                            Button(welcomeFeature.title ?? ConcordString.welcomeTitle(platform.appName)) {
                                application.showWelcomeFeature()
                            }
                        }
                        if let getStartedFeature = application.getStartedFeature {
                            Button(getStartedFeature.title ?? ConcordString.getStarted) {
                                application.showGetStartedFeature()
                            }
                        }
                        if let whatsNewFeature = application.whatsNewFeature {
                            Button(whatsNewFeature.title ?? ConcordString.whatsNew) {
                                application.showWhatsNewFeature()
                            }
                        }
                        if let faqFeature = application.faqFeature {
                            Button(faqFeature.title ?? ConcordString.faqTitle(platform.appName)) {
                                application.showFAQFeature()
                            }
                        }
                        if !application.helpActions.isEmpty {
                            if application.helpFeature != nil
                                || application.welcomeFeature != nil
                                || application.getStartedFeature != nil
                                || application.whatsNewFeature != nil
                                || application.faqFeature != nil {
                                Divider()
                            }
                            ForEach(Array(application.helpActions.enumerated()), id: \.offset) { _, action in
                                Button(action.title) {
                                    action.invoke()
                                }
                            }
                        }
                    }
                }
            }
        }
        #else
        WindowGroup {
            ConcordAppleRootView(platform: platform)
                .onAppear {
                    application?.completeStandardAppStart()
                }
        }
        #endif
    }
}

#if os(macOS)
@MainActor
private struct ConcordAppleConfiguredRootView: View {
    @ObservedObject var platform: ConcordApplePlatform
    let application: ConcordApplication?

    var body: some View {
        ConcordAppleRootView(platform: platform)
            .onAppear {
                application?.completeStandardAppStart()
                if let application {
                    DispatchQueue.main.async {
                        installConcordActionGroupMenus(for: application)
                    }
                }
            }
            .background {
                ConcordAppleWindowConfigurator(
                    venueID: application?.mainVenue.id ?? platform.currentVenue?.id,
                    config: application?.mainVenue.config ?? platform.currentVenue?.config
                )
                .frame(width: 0, height: 0)
            }
    }
}

@MainActor
private final class ConcordAppleWindowConfigurationView: NSView {
    var venueID: String?
    var config: ConcordVenueConfig?

    private var initialSizeVenueID: String?
    private var pendingConfiguration = false
    private var lastAppliedVenueID: String?
    private var lastAppliedConfig: ConcordVenueConfig?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        scheduleConfiguration()
    }

    func scheduleConfiguration() {
        guard !pendingConfiguration else { return }
        pendingConfiguration = true

        DispatchQueue.main.async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.pendingConfiguration = false
                self.applyConfigurationIfNeeded()
            }
        }
    }

    private func applyConfigurationIfNeeded() {
        guard let window, let venueID, let config else { return }
        guard lastAppliedVenueID != venueID || lastAppliedConfig != config else { return }

        if let name = config.name, window.title != name {
            window.title = name
        }

        if window.styleMask.contains(.fullSizeContentView) {
            window.styleMask.remove(.fullSizeContentView)
        }
        if !window.styleMask.contains(.titled) {
            window.styleMask.insert(.titled)
        }
        if window.titleVisibility != .visible {
            window.titleVisibility = .visible
        }
        if window.titlebarAppearsTransparent {
            window.titlebarAppearsTransparent = false
        }

        // Keep AppKit's closable style so the title bar reserves the standard
        // traffic-light area. Removing the style moves the title underneath the
        // minimize and zoom controls on current macOS versions.
        if !window.styleMask.contains(.closable) {
            window.styleMask.insert(.closable)
        }
        if let closeButton = window.standardWindowButton(.closeButton) {
            closeButton.isHidden = false
            closeButton.isEnabled = config.closable
            // Keep the button visible even when closing is disabled. A fully
            // transparent Close button lets macOS place the leading window
            // title inside the traffic-light area.
            closeButton.alphaValue = 1
        }

        if let minSize = config.minSize {
            let nativeMinSize = NSSize(width: minSize.horizontal, height: minSize.vertical)
            if window.contentMinSize != nativeMinSize {
                window.contentMinSize = nativeMinSize
            }
        }

        if let maxSize = config.maxSize {
            let nativeMaxSize = NSSize(width: maxSize.horizontal, height: maxSize.vertical)
            if window.contentMaxSize != nativeMaxSize {
                window.contentMaxSize = nativeMaxSize
            }
        }

        if initialSizeVenueID != venueID,
           let initialSize = config.initialSize {
            let nativeInitialSize = NSSize(
                width: initialSize.horizontal,
                height: initialSize.vertical
            )
            if window.contentView?.frame.size != nativeInitialSize {
                window.setContentSize(nativeInitialSize)
            }
            initialSizeVenueID = venueID
        }

        lastAppliedVenueID = venueID
        lastAppliedConfig = config
    }
}

@MainActor
private struct ConcordAppleWindowConfigurator: NSViewRepresentable {
    let venueID: String?
    let config: ConcordVenueConfig?

    func makeNSView(context: Context) -> ConcordAppleWindowConfigurationView {
        ConcordAppleWindowConfigurationView(frame: .zero)
    }

    func updateNSView(_ nsView: ConcordAppleWindowConfigurationView, context: Context) {
        nsView.venueID = venueID
        nsView.config = config
        nsView.scheduleConfiguration()
    }
}

@MainActor
private final class ConcordAppleActionTarget: NSObject {
    let action: ConcordTitleAction

    init(action: ConcordTitleAction) {
        self.action = action
    }

    @objc func invoke() {
        action.invoke()
    }
}

@MainActor
private var concordActionMenuTargets: [ObjectIdentifier: [ConcordAppleActionTarget]] = [:]

@MainActor
private func installConcordActionGroupMenus(for application: ConcordApplication) {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }

    let identifierPrefix = "concordui.action-group."
    for item in mainMenu.items.reversed()
        where item.identifier?.rawValue.hasPrefix(identifierPrefix) == true {
        mainMenu.removeItem(item)
    }

    var insertionIndex = mainMenu.items.count
    if let windowMenu = NSApplication.shared.windowsMenu,
       let index = mainMenu.items.firstIndex(where: { $0.submenu === windowMenu }) {
        insertionIndex = min(insertionIndex, index)
    }
    if let helpMenu = NSApplication.shared.helpMenu,
       let index = mainMenu.items.firstIndex(where: { $0.submenu === helpMenu }) {
        insertionIndex = min(insertionIndex, index)
    }

    var targets: [ConcordAppleActionTarget] = []
    for group in application.displayedActionGroups {
        let submenu = NSMenu(title: group.title)
        for action in group.actions {
            let target = ConcordAppleActionTarget(action: action)
            let item = NSMenuItem(
                title: action.title,
                action: #selector(ConcordAppleActionTarget.invoke),
                keyEquivalent: ""
            )
            item.target = target
            submenu.addItem(item)
            targets.append(target)
        }

        let menuItem = NSMenuItem(title: group.title, action: nil, keyEquivalent: "")
        menuItem.identifier = NSUserInterfaceItemIdentifier(identifierPrefix + group.tag)
        menuItem.submenu = submenu
        mainMenu.insertItem(menuItem, at: insertionIndex)
        insertionIndex += 1
    }

    concordActionMenuTargets[ObjectIdentifier(application)] = targets
}
#endif
