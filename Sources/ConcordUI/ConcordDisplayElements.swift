//
//  ConcordDisplayElements.swift
//  ConcordUI
//
//  Portable image/icon and progress display elements.
//

import Foundation

// MARK: - Image / Icon

/// Common semantic icons that each platform maps to its native icon library.
public enum ConcordStandardIcon: String, Sendable, CaseIterable {
    /// Generic application icon. Each platform maps this to its normal app/application symbol.
    case app
    case home
    case settings
    case information
    case welcome
    case getStarted
    case whatsNew
    case faq
    case help
    case search
    case add
    case remove
    case check
    case warning
    case error
}

/// Portable image content understood by the current ConcordUI backends.
///
/// An icon is image data with a semantic, platform-resolved origin rather than
/// a separate UI concept. Future image work can add encoded bitmap/vector data
/// here once both platform renderers support it. A URL is intentionally not an
/// image-data case: future networking APIs will load a URL and produce
/// `ConcordImageData`.
public enum ConcordImageData: Sendable, Equatable {
    /// An application asset/resource using its platform resource name.
    case asset(String)

    /// A semantic icon mapped to the native platform icon library.
    case icon(ConcordStandardIcon)
}

/// Displays portable ConcordUI image data.
public final class ConcordImage: ConcordElement {
    public var imageData: ConcordImageData {
        didSet {
            guard oldValue != imageData else { return }
            notifyPresentationChanged()
        }
    }

    /// Keeps the image's layout square while it expands to the available width.
    public var fillsSquare: Bool {
        didSet {
            guard oldValue != fillsSquare else { return }
            notifyPresentationChanged()
        }
    }

    /// Creates an image from portable image data.
    public init(_ imageData: ConcordImageData) {
        self.imageData = imageData
        self.fillsSquare = false
        super.init()
    }

    @discardableResult
    public func fillSquare() -> Self {
        fillsSquare = true
        return self
    }

    /// Convenience initializer for an application asset/resource name.
    public convenience init(_ assetName: String) {
        self.init(.asset(assetName))
    }

    /// Convenience constructor for a semantic standard icon.
    public static func icon(_ icon: ConcordStandardIcon) -> ConcordImage {
        ConcordImage(.icon(icon))
    }

    /// Compatibility view of the former image source property.
    public var source: ConcordImageData { imageData }
}

/// Compatibility alias for code written before `ConcordImage` became the
/// public image element name.
@available(*, deprecated, renamed: "ConcordImage")
public typealias ConcordImageElement = ConcordImage

/// Compatibility alias for the former image source name.
@available(*, deprecated, renamed: "ConcordImageData")
public typealias ConcordImageSource = ConcordImageData

// MARK: - Progress

public enum ConcordProgressFlavor: Sendable, Equatable {
    /// Determinate progress displayed as a native progress bar.
    case bar

    /// Indeterminate native activity indicator.
    case spinner
}

/// Displays determinate or indeterminate progress using native platform controls.
public final class ConcordProgressElement: ConcordElement {
    public let flavor: ConcordProgressFlavor
    public var label: String

    /// A normalized value from 0.0 through 1.0 for `.bar` progress.
    /// Spinner progress ignores this value.
    public var value: ConcordFloat {
        didSet {
            value = min(max(value, 0), 1)
            if oldValue != value { notifyPresentationChanged() }
        }
    }

    public init(_ flavor: ConcordProgressFlavor, label: String = "", value: ConcordFloat = 0) {
        self.flavor = flavor
        self.label = label
        self.value = min(max(value, 0), 1)
        super.init()
    }

    @discardableResult
    public func progress(_ value: ConcordFloat) -> Self {
        self.value = value
        return self
    }
}