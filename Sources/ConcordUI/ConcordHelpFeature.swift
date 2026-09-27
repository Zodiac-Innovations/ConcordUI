//
//  ConcordHelpFeature.swift
//  ConcordUI
//
//  Application-level Help behavior.
//

public extension ConcordApplication {
    /// Creates a button that invokes this application's configured Help feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordHelpFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? helpFeature?.title ?? ConcordString.helpTitle(platform.appName)
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .help
        ) { [weak self] in
            self?.showHelpFeature()
        }
    }
}
