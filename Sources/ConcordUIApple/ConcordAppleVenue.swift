import ConcordUI
import SwiftUI
#if os(macOS)
import AppKit
#endif

public extension ConcordApplePlatform {
    /// The ConcordUI Venue currently realized by the Apple root host.
    ///
    /// On macOS the root host remains the Main Venue while Secondary Venues use their
    /// own native windows. On iOS/iPadOS the root host displays whichever Venue is on top.
    var currentVenue: ConcordVenue? {
        currentPresentation?.venue
    }

    var isDisplayingMainVenue: Bool {
        currentVenue?.config.kind == .main
    }

    func displayPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        #if os(macOS)
        if let modal = venue as? ConcordModalVenue {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            let presentation = ConcordAppleUncheckedSendable(presentation)
            let modal = ConcordAppleUncheckedSendable(modal)

            MainActor.assumeIsolated {
                var hosts = concordAppleModalVenueHosts[platformKey] ?? [:]
                if let host = hosts[venueID] {
                    host.display(presentation.value)
                } else {
                    let parentWindow = concordAppleParentWindow(
                        for: modal.value.ownerVenue,
                        platformKey: platformKey
                    )
                    let host = ConcordAppleModalVenueHost(
                        presentation: presentation.value,
                        modal: modal.value,
                        parentWindow: parentWindow
                    )
                    hosts[venueID] = host
                    concordAppleModalVenueHosts[platformKey] = hosts
                    host.show()
                }
            }
            return
        }
        if venue.config.kind == .secondary {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            let config = venue.config
            let presentation = ConcordAppleUncheckedSendable(presentation)

            MainActor.assumeIsolated {
                var hosts = concordAppleSecondaryVenueHosts[platformKey] ?? [:]

                if let host = hosts[venueID] {
                    host.display(presentation.value, config: config)
                } else {
                    let host = ConcordAppleSecondaryVenueHost(
                        presentation: presentation.value,
                        config: config
                    )
                    hosts[venueID] = host
                    concordAppleSecondaryVenueHosts[platformKey] = hosts
                }
            }
            return
        }
        #else
        if venue.config.kind == .secondary || venue.config.kind == .modal {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            let currentVenueID = currentVenue?.id
            let previous = currentPresentation.map(ConcordAppleUncheckedSendable.init)

            MainActor.assumeIsolated {
                var previousByVenue = concordApplePreviousPresentations[platformKey] ?? [:]
                if currentVenueID != venueID,
                   previousByVenue[venueID] == nil,
                   let previous {
                    previousByVenue[venueID] = previous.value
                    concordApplePreviousPresentations[platformKey] = previousByVenue
                }
            }
        }
        #endif

        displayPresentation(presentation)
    }

    func refreshPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        #if os(macOS)
        if venue.config.kind == .modal {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            let presentation = ConcordAppleUncheckedSendable(presentation)
            MainActor.assumeIsolated {
                concordAppleModalVenueHosts[platformKey]?[venueID]?.refresh(presentation.value)
            }
            return
        }
        if venue.config.kind == .secondary {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            let config = venue.config
            let presentation = ConcordAppleUncheckedSendable(presentation)

            MainActor.assumeIsolated {
                guard let host = concordAppleSecondaryVenueHosts[platformKey]?[venueID] else { return }
                host.refresh(presentation.value, config: config)
            }
            return
        }
        #endif

        refreshPresentation(presentation)
    }
}

extension ConcordApplePlatform: ConcordVenuePlatformLifecycle {
    public func closeVenue(_ venue: ConcordVenue) {
        #if os(macOS)
        if venue.config.kind == .secondary {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id

            MainActor.assumeIsolated {
                concordAppleSecondaryVenueHosts[platformKey]?[venueID]?.close()
            }
            return
        }
        #else
        if venue.config.kind == .secondary || venue.config.kind == .modal {
            restorePreviousPresentation(for: venue)
            return
        }
        #endif
    }

    public func dismissVenue(_ venue: ConcordVenue) {
        #if os(macOS)
        if venue.config.kind == .modal {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id
            MainActor.assumeIsolated {
                guard var hosts = concordAppleModalVenueHosts[platformKey] else { return }
                hosts.removeValue(forKey: venueID)?.close()
                concordAppleModalVenueHosts[platformKey] = hosts
            }
            return
        }
        if venue.config.kind == .secondary {
            let platformKey = ObjectIdentifier(self)
            let venueID = venue.id

            MainActor.assumeIsolated {
                guard var hosts = concordAppleSecondaryVenueHosts[platformKey] else { return }
                hosts.removeValue(forKey: venueID)?.close()
                concordAppleSecondaryVenueHosts[platformKey] = hosts
            }
            return
        }
        #else
        if venue.config.kind == .secondary || venue.config.kind == .modal {
            restorePreviousPresentation(for: venue)
            return
        }
        #endif
    }

    #if !os(macOS)
    private func restorePreviousPresentation(for venue: ConcordVenue) {
        guard currentVenue?.id == venue.id else { return }

        let platformKey = ObjectIdentifier(self)
        let venueID = venue.id

        let previous = MainActor.assumeIsolated { () -> ConcordAppleUncheckedSendable<ConcordPresentation>? in
            var previousByVenue = concordApplePreviousPresentations[platformKey] ?? [:]
            let previous = previousByVenue.removeValue(forKey: venueID)
            concordApplePreviousPresentations[platformKey] = previousByVenue
            return previous.map(ConcordAppleUncheckedSendable.init)
        }

        if let previous {
            displayPresentation(previous.value)
        } else if let mainPresentation = venue.application?.mainVenue.currentPresentation {
            displayPresentation(mainPresentation)
        }
    }
    #endif
}

/// Carries a framework reference across the synchronous main-actor boundary used
/// by native Venue hosting without declaring the mutable core model Sendable.
private struct ConcordAppleUncheckedSendable<Value>: @unchecked Sendable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }
}

#if os(macOS)
@MainActor
private final class ConcordAppleSecondaryVenueHost {
    let platform: ConcordApplePlatform
    let window: NSWindow
    private let initialSize: ConcordVenueSize

    init(presentation: ConcordPresentation, config: ConcordVenueConfig) {
        let platform = ConcordApplePlatform()
        self.platform = platform
        platform.displayPresentation(presentation)

        let initial = config.initialSize ?? ConcordVenueSize(640, 480)
        self.initialSize = initial

        let styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .miniaturizable,
            .resizable,
        ]

        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: initial.horizontal,
                height: initial.vertical
            ),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        self.window = window

        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(
            rootView: ConcordAppleRootView(platform: platform)
        )
        apply(config)

        // Setting a SwiftUI hosting controller can influence the window's fitting size.
        // Reassert the requested Venue content size after installing the host so a new
        // Secondary Venue cannot end up as an effectively invisible zero-sized window.
        window.setContentSize(NSSize(width: initial.horizontal, height: initial.vertical))
        window.center()
        show()
    }

    func display(_ presentation: ConcordPresentation, config: ConcordVenueConfig) {
        platform.displayPresentation(presentation)
        apply(config)

        // A previously closed NSWindow is retained by its Venue host. Reassert a usable
        // content size before showing it again in case AppKit/SwiftUI changed its frame.
        if window.contentLayoutRect.width < 100 || window.contentLayoutRect.height < 100 {
            window.setContentSize(NSSize(width: initialSize.horizontal, height: initialSize.vertical))
            window.center()
        }
        show()
    }

    func refresh(_ presentation: ConcordPresentation, config: ConcordVenueConfig) {
        platform.refreshPresentation(presentation)
        apply(config)
    }

    func close() {
        window.close()
    }

    private func show() {
        // makeKeyAndOrderFront normally suffices, but a programmatically-created window
        // owned outside SwiftUI's WindowGroup can otherwise become a Window-menu entry
        // without being ordered visibly in front of the app's scene window.
        NSApp.activate(ignoringOtherApps: true)
        window.setIsVisible(true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    private func apply(_ config: ConcordVenueConfig) {
        if let name = config.name {
            window.title = name
        }

        if !window.styleMask.contains(.closable) {
            window.styleMask.insert(.closable)
        }
        if let closeButton = window.standardWindowButton(.closeButton) {
            closeButton.isHidden = false
            closeButton.isEnabled = config.closable
            closeButton.alphaValue = config.closable ? 1 : 0
        }

        if let minSize = config.minSize {
            window.contentMinSize = NSSize(width: minSize.horizontal, height: minSize.vertical)
        }
        if let maxSize = config.maxSize {
            window.contentMaxSize = NSSize(width: maxSize.horizontal, height: maxSize.vertical)
        }

        if let minSize = config.minSize, minSize == config.maxSize {
            window.styleMask.remove(.resizable)
            window.setContentSize(NSSize(width: minSize.horizontal, height: minSize.vertical))
        } else {
            window.styleMask.insert(.resizable)
        }
    }
}

@MainActor
private final class ConcordAppleModalVenueHost {
    let platform: ConcordApplePlatform
    let window: NSWindow
    private weak var parentWindow: NSWindow?
    private let flavor: ConcordModalVenueFlavor
    private var isRunningModal = false

    init(
        presentation: ConcordPresentation,
        modal: ConcordModalVenue,
        parentWindow: NSWindow?
    ) {
        let platform = ConcordApplePlatform()
        self.platform = platform
        self.parentWindow = parentWindow
        self.flavor = modal.flavor
        platform.displayPresentation(presentation)

        let initial = modal.config.initialSize ?? ConcordVenueSize(420, 280)
        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: initial.horizontal,
                height: initial.vertical
            ),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        self.window = window
        window.isReleasedWhenClosed = false
        window.title = modal.config.name ?? ""
        window.contentViewController = NSHostingController(
            rootView: ConcordAppleRootView(platform: platform)
        )
        window.setContentSize(NSSize(width: initial.horizontal, height: initial.vertical))
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isEnabled = false
    }

    func display(_ presentation: ConcordPresentation) {
        platform.displayPresentation(presentation)
        if !window.isVisible { show() }
    }

    func refresh(_ presentation: ConcordPresentation) {
        platform.refreshPresentation(presentation)
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        switch flavor {
        case .sheet:
            if let parentWindow {
                parentWindow.beginSheet(window)
            } else {
                window.center()
                window.makeKeyAndOrderFront(nil)
            }
        case .dialog:
            if let parentWindow {
                parentWindow.addChildWindow(window, ordered: .above)
                let parentFrame = parentWindow.frame
                let dialogFrame = window.frame
                window.setFrameOrigin(NSPoint(
                    x: parentFrame.midX - dialogFrame.width / 2,
                    y: parentFrame.midY - dialogFrame.height / 2
                ))
            } else {
                window.center()
            }
            window.makeKeyAndOrderFront(nil)
            isRunningModal = true
            _ = NSApp.runModal(for: window)
            isRunningModal = false
        }
    }

    func close() {
        if isRunningModal { NSApp.stopModal() }
        if window.sheetParent != nil {
            window.sheetParent?.endSheet(window)
        }
        parentWindow?.removeChildWindow(window)
        window.close()
    }
}

@MainActor
private func concordAppleParentWindow(
    for ownerVenue: ConcordVenue?,
    platformKey: ObjectIdentifier
) -> NSWindow? {
    if let ownerVenue, ownerVenue.config.kind == .secondary {
        return concordAppleSecondaryVenueHosts[platformKey]?[ownerVenue.id]?.window
    }
    return NSApp.keyWindow ?? NSApp.mainWindow
}

@MainActor
private var concordAppleSecondaryVenueHosts: [
    ObjectIdentifier: [String: ConcordAppleSecondaryVenueHost]
] = [:]

@MainActor
private var concordAppleModalVenueHosts: [
    ObjectIdentifier: [String: ConcordAppleModalVenueHost]
] = [:]
#else
@MainActor
private var concordApplePreviousPresentations: [
    ObjectIdentifier: [String: ConcordPresentation]
] = [:]
#endif
