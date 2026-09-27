//
//  ConcordWelcomeFeature.swift
//  ConcordUI
//
//  Standard Welcome feature behavior and presentation.
//

/// Creates a text-and-icon button that invokes the application's Welcome feature.
/// The configured title is used as the button's accessibility label.

/// Installs the standard Welcome Presentation.
public extension ConcordApplication {
    /// Creates a button that invokes this application's configured feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordWelcomeFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? welcomeFeature?.title
            ?? ConcordString.welcomeTitle(platform.appName)
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .welcome
        ) { [weak self] in
            self?.showWelcomeFeature()
        }
    }


    @discardableResult
    func useStandardWelcomeFeature(
        images: [ConcordImageData],
        title: String? = nil,
        subHeader: String? = nil
    ) -> Self {
        let platform = self.platform
        let resolvedTitle = title ?? ConcordString.welcomeTitle(platform.appName)
        welcomeFeature = ConcordFeatureConfig(
            title: resolvedTitle,
            presentation: {
                let flavor: ConcordOverlappingImagesFlavor =
                    platform.deviceType == .desktop ? .stacked : .bottomLeftToTopRight
                var content: [ConcordElement] = [
                    ConcordText(resolvedTitle)
                        .fontSize(platform.deviceType == .desktop ? 36 : 28)
                        .centerJustified(),
                    ConcordDivider()
                ]
                if let subHeader, !subHeader.isEmpty {
                    content.append(
                        ConcordText(subHeader)
                            .fontSize(platform.deviceType == .desktop ? 20 : 18)
                            .centerJustified()
                    )
                }
                content.append(
                    ConcordOverlappingImagesElement(
                        flavor,
                        images: images,
                        width: 640,
                        height: 400
                    )
                    .fillSize()
                    .centerJustified()
                )

                return ConcordPresentation {
                    ConcordWorkStack(content)
                }
            },
            preferredWindowSize: (width: 800, height: 600),
            dismissAble: true
        )
        return self
    }
}
