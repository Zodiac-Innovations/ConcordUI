//
//  ConcordVenue.swift
//  ConcordUI
//
//  Defines portable hosting contexts for ConcordUI Presentations.
//

import Foundation

public enum ConcordVenueKind: Sendable, Equatable {
    case main
    case secondary
    case modal
}

/// Controls the native desktop appearance of a Modal Venue. Mobile platforms
/// present both flavors as a modal screen.
public enum ConcordModalVenueFlavor: Sendable, Equatable {
    case dialog
    case sheet
}

public enum ConcordVenueID {
    public static let reservedPrefix = "concordui."
    public static let reservedFeaturePrefix = "concordui-"
    public static let main = "concordui.main"
    public static let about = "concordui-about"
    public static let welcome = "concordui-welcome"
    public static let getStarted = "concordui-get-started"
    public static let settings = "concordui.settings"
    public static let whatsNew = "concordui.whatsnew"
    public static let faq = "concordui-faq"
    public static let help = "concordui.help"

    public static func isReserved(_ id: String) -> Bool {
        id.hasPrefix(reservedPrefix) || id.hasPrefix(reservedFeaturePrefix)
    }
}

public struct ConcordVenueSize: Sendable, Equatable {
    public var horizontal: Double
    public var vertical: Double

    public init(_ horizontal: Double, _ vertical: Double) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

public struct ConcordVenueConfig: Sendable, Equatable {
    public var kind: ConcordVenueKind
    public var name: String?
    public var closable: Bool
    /// Allows a Secondary Venue to add its own dismiss control on mobile.
    public var dismissAble: Bool
    /// Label for the dismiss control; nil uses ConcordString.ok.
    public var closeLabel: String?
    public var initialSize: ConcordVenueSize?
    public var minSize: ConcordVenueSize?
    public var maxSize: ConcordVenueSize?

    public init(
        kind: ConcordVenueKind,
        name: String? = nil,
        closable: Bool = false,
        dismissAble: Bool = false,
        closeLabel: String? = nil,
        initialSize: ConcordVenueSize? = nil,
        minSize: ConcordVenueSize? = nil,
        maxSize: ConcordVenueSize? = nil
    ) {
        self.kind = kind
        self.name = name
        self.closable = closable
        self.dismissAble = dismissAble
        self.closeLabel = closeLabel
        self.initialSize = initialSize
        self.minSize = minSize
        self.maxSize = maxSize
    }

    internal static func main(name: String) -> ConcordVenueConfig {
        ConcordVenueConfig(
            kind: .main,
            name: name,
            closable: false,
            initialSize: ConcordVenueSize(640, 480),
            minSize: ConcordVenueSize(320, 240),
            maxSize: ConcordVenueSize(1280, 960)
        )
    }
}

/// Platform hooks for closing a Venue realization temporarily or removing it permanently.
public protocol ConcordVenuePlatformLifecycle: AnyObject {
    func closeVenue(_ venue: ConcordVenue)
    func dismissVenue(_ venue: ConcordVenue)
}

open class ConcordVenue: ConcordActionDispatching, ConcordElementChangeDispatching {
    public let id: String
    public private(set) weak var application: ConcordApplication?
    public private(set) var currentPresentation: ConcordPresentation?
    public private(set) var config: ConcordVenueConfig
    public var currentData: (any ConcordDataProtocol)?
    public var displayOptions: ConcordDisplayOptions?
    public var isDisplayed: Bool { currentPresentation != nil }

    private var presentationBuilders: [Int: ConcordPresentationBuilder] = [:]
    private var modalVenues: [ConcordModalVenue] = []

    internal init(
        id: String,
        application: ConcordApplication? = nil,
        config: ConcordVenueConfig,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) {
        precondition(!id.isEmpty, "ConcordUI Venue identifiers must not be empty.")
        self.id = id
        self.application = application
        self.config = config
        self.currentData = currentData
        self.displayOptions = displayOptions
    }

    internal func attach(to application: ConcordApplication) {
        self.application = application
    }

    @discardableResult public func venue(name: String) -> Self { config.name = name; refreshVenueConfiguration(); return self }
    @discardableResult public func closable(_ closable: Bool = true) -> Self { config.closable = closable; refreshVenueConfiguration(); return self }
    @discardableResult public func size(_ horizontal: Double, _ vertical: Double) -> Self { config.initialSize = ConcordVenueSize(horizontal, vertical); refreshVenueConfiguration(); return self }
    @discardableResult public func minSize(_ horizontal: Double, _ vertical: Double) -> Self { config.minSize = ConcordVenueSize(horizontal, vertical); refreshVenueConfiguration(); return self }
    @discardableResult public func maxSize(_ horizontal: Double, _ vertical: Double) -> Self { config.maxSize = ConcordVenueSize(horizontal, vertical); refreshVenueConfiguration(); return self }

    private func refreshVenueConfiguration() {
        guard let application, let presentation = currentPresentation else { return }
        application.platform.refreshPresentation(presentation, in: self)
    }

    public func registerPresentation(tag: Int, builder: @escaping ConcordPresentationBuilder) {
        precondition(tag > 0, "ConcordUI Presentation registration tags must be positive. Zero is invalid and negative tags are reserved by ConcordUI.")
        presentationBuilders[tag] = builder
    }
    public func unregisterPresentation(tag: Int) { presentationBuilders.removeValue(forKey: tag) }
    public func registeredPresentationBuilder(tag: Int) -> ConcordPresentationBuilder? { presentationBuilders[tag] }
    public func hasPresentation(tag: Int) -> Bool { presentationBuilders[tag] != nil }
    internal func registerSystemPresentation(tag: Int, builder: @escaping ConcordPresentationBuilder) {
        precondition(tag < 0, "ConcordUI system Presentation tags must be negative.")
        presentationBuilders[tag] = builder
    }

    /// Registers this Venue's Home Presentation. Every Venue may have its own Home.
    public func registerHome(builder: @escaping ConcordPresentationBuilder) {
        registerSystemPresentation(tag: ConcordSystemPresentationTag.home, builder: builder)
    }

    /// Displays this Venue's registered Home Presentation, if one exists.
    @discardableResult
    public func displayHome(data: (any ConcordDataProtocol)? = nil) -> ConcordPresentation? {
        displayPresentation(tag: ConcordSystemPresentationTag.home, data: data)
    }

    @discardableResult
    public func displayPresentation(tag: Int, data: (any ConcordDataProtocol)? = nil) -> ConcordPresentation? {
        guard let builder = presentationBuilders[tag] else { return nil }
        let effectiveData = data ?? currentData
        let presentation = builder(effectiveData)
        presentation.data = effectiveData
        displayPresentation(presentation, data: effectiveData)
        return presentation
    }

    public func displayPresentation(_ presentation: ConcordPresentation, data: (any ConcordDataProtocol)? = nil) {
        guard let application else { return }
        if let data { presentation.data = data } else if presentation.data == nil { presentation.data = currentData }
        finishAndCleanupCurrentPresentation()
        presentation.startPresentation()
        presentation.buildElements()
        if config.kind == .secondary, config.dismissAble, application.platform.deviceType != .desktop {
            let button = ConcordButton(config.closeLabel ?? ConcordString.ok) { [weak self] in
                self?.closeVenue()
            }
            presentation.appendElementToBottom(button.centerJustified())
        }
        currentPresentation = presentation
        presentation.venue = self
        applyResolvedDisplayInformation(to: presentation)
        presentation.attachDispatchers(actionDispatcher: self, changeDispatcher: self)
        application.platform.displayPresentation(presentation, in: self)
    }

    /// Closes the native realization of this Venue without removing the Venue or
    /// finishing its current Presentation. Desktop platforms close the Venue window;
    /// mobile platforms pop it and restore the previously visible Venue/Presentation.
    public func closeVenue() {
        guard config.kind != .main,
              let lifecycle = application?.platform as? any ConcordVenuePlatformLifecycle else {
            return
        }
        dismissOwnedModalVenues()
        lifecycle.closeVenue(self)
    }

    public func clearPresentation() { finishAndCleanupCurrentPresentation() }
    internal func refreshDisplayInformation() {
        guard let application, let presentation = currentPresentation else { return }
        applyResolvedDisplayInformation(to: presentation)
        application.platform.refreshPresentation(presentation, in: self)
    }

    private func applyResolvedDisplayInformation(to presentation: ConcordPresentation) {
        guard let application else { return }
        var information = application.displayInformation
        if let displayOptions { information = information.applying(displayOptions) }
        if let presentationOptions = presentation.displayOptions { information = information.applying(presentationOptions) }
        presentation.applyDisplayInformation(information)
    }

    private func finishAndCleanupCurrentPresentation() {
        guard let presentation = currentPresentation else { return }
        presentation.finishPresentation()
        presentation.cleanupAfterFinish()
        presentation.venue = nil
        currentPresentation = nil
    }

    @discardableResult
    public func createModalVenue(
        flavor: ConcordModalVenueFlavor = .dialog,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) -> ConcordModalVenue {
        let modalID = "modal.\(UUID().uuidString.lowercased())"
        let modal = ConcordModalVenue(
            id: modalID,
            application: application,
            ownerVenue: self,
            flavor: flavor,
            currentData: currentData,
            displayOptions: displayOptions
        )
        modalVenues.append(modal)
        return modal
    }
    internal func releaseModalVenue(_ modal: ConcordModalVenue) { modalVenues.removeAll { $0 === modal } }
    internal func dismissOwnedModalVenues() {
        let venues = modalVenues
        for modal in venues { modal.dismiss() }
    }

    internal func dispatchAction(_ event: ConcordActionEvent) {
        if let presentation = currentPresentation {
            if let action = presentation.action { action(event); return }
            if presentation.handleAction(event) { return }
        }
        application?.dispatchApplicationAction(event)
    }

    internal func elementDidChange(_ element: ConcordElement) {
        guard let presentation = currentPresentation else { return }
        presentation.elementDidChange(element)
        application?.platform.refreshPresentation(presentation, in: self)
    }
}

public final class ConcordMainVenue: ConcordVenue {
    internal init(
        application: ConcordApplication? = nil,
        name: String = ConcordString.application,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) {
        super.init(
            id: ConcordVenueID.main,
            application: application,
            config: .main(name: name),
            currentData: currentData,
            displayOptions: displayOptions
        )
    }
}

public final class ConcordSecondaryVenue: ConcordVenue {
    internal override init(
        id: String,
        application: ConcordApplication? = nil,
        config: ConcordVenueConfig,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) {
        precondition(config.kind == .secondary, "ConcordSecondaryVenue requires a .secondary ConcordVenueConfig.")
        super.init(id: id, application: application, config: config, currentData: currentData, displayOptions: displayOptions)
    }
}

@available(*, deprecated, renamed: "ConcordSecondaryVenue")
public typealias ConcordAuxiliaryVenue = ConcordSecondaryVenue

public final class ConcordModalVenue: ConcordVenue {
    public private(set) weak var ownerVenue: ConcordVenue?
    public let flavor: ConcordModalVenueFlavor

    internal init(
        id: String,
        application: ConcordApplication? = nil,
        ownerVenue: ConcordVenue,
        flavor: ConcordModalVenueFlavor,
        currentData: (any ConcordDataProtocol)? = nil,
        displayOptions: ConcordDisplayOptions? = nil
    ) {
        self.ownerVenue = ownerVenue
        self.flavor = flavor
        super.init(
            id: id,
            application: application,
            config: ConcordVenueConfig(kind: .modal),
            currentData: currentData,
            displayOptions: displayOptions
        )
    }

    public func dismiss() {
        if let lifecycle = application?.platform as? any ConcordVenuePlatformLifecycle {
            lifecycle.dismissVenue(self)
        }
        clearPresentation()
        let owner = ownerVenue
        ownerVenue = nil
        owner?.releaseModalVenue(self)
    }
}
