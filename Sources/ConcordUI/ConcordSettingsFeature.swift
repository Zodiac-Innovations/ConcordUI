//
//  ConcordSettingsFeature.swift
//  ConcordUI
//
//  Application-level Settings behavior.
//

/// Creates a text-and-icon button that invokes the application's Settings feature.
/// The supplied title overrides the configured title and is retained for accessibility.

public extension ConcordApplication {
    /// Creates a button that invokes this application's configured feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordSettingsFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? settingsFeature?.title ?? ConcordString.settings
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .settings
        ) { [weak self] in
            self?.showSettingsFeature()
        }
    }


}
