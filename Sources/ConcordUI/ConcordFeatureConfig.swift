//
//  ConcordFeatureConfig.swift
//  ConcordUI
//
//  Reusable application-level feature configuration.
//

/// Describes either an app-managed feature action or a feature Presentation
/// whose Secondary Venue is managed by ConcordUI.
public struct ConcordFeatureConfig {
    /// Overrides the feature's default presentation title when provided.
    public let title: String?

    /// Handles the feature completely when provided.
    public let action: (() -> Void)?

    /// Builds a fresh Presentation whenever the feature is invoked.
    public let presentation: (() -> ConcordPresentation)?

    /// Preferred desktop window size in points; ignored by native mobile venues.
    public let preferredWindowSize: (width: Int, height: Int)?

    /// Requests a venue-provided dismiss control on mobile.
    public let dismissAble: Bool

    /// Optional label for the mobile dismiss control.
    public let closeLabel: String?

    public init(
        title: String? = nil,
        action: (() -> Void)? = nil,
        presentation: (() -> ConcordPresentation)? = nil,
        preferredWindowSize: (width: Int, height: Int)? = nil,
        dismissAble: Bool = false,
        closeLabel: String? = nil
    ) {
        precondition(action == nil || presentation == nil,
                     "A feature must use either an action or a Presentation.")
        if let preferredWindowSize {
            precondition(preferredWindowSize.width > 0 && preferredWindowSize.height > 0,
                         "Feature window dimensions must be positive.")
        }
        self.title = title
        self.action = action
        self.presentation = presentation
        self.preferredWindowSize = preferredWindowSize
        self.dismissAble = dismissAble
        self.closeLabel = closeLabel
    }
}
