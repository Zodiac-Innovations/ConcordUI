//
//  ConcordGetStartedFeature.swift
//  ConcordUI
//
//  Standard Get Started feature behavior and presentation.
//

/// Creates a text-and-icon button that invokes the application's Get Started feature.
/// The configured title is used as the button's accessibility label.

/// Installs the standard Get Started Presentation.
public extension ConcordApplication {
    /// Creates a button that invokes this application's configured feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordGetStartedFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? getStartedFeature?.title ?? ConcordString.getStarted
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .getStarted
        ) { [weak self] in
            self?.showGetStartedFeature()
        }
    }


    @discardableResult
    func useStandardGetStartedFeature(
        summaries: [ConcordSummaryData],
        title: String? = nil,
        centerAccess: ConcordAccessData? = nil,
        accessList: [ConcordAccessData] = []
    ) -> Self {
        let resolvedTitle = title ?? ConcordString.getStarted
        let platform = self.platform
        getStartedFeature = ConcordFeatureConfig(
            title: resolvedTitle,
            presentation: {
                var content: [ConcordElement] = [
                    ConcordText(resolvedTitle)
                        .bold()
                        .fontSize(platform.deviceType == .desktop ? 36 : 28)
                        .centerJustified(),
                    ConcordDivider()
                ]

                content.append(contentsOf: summaries.map { summary in
                    ConcordHStack([
                        ConcordImage(summary.image)
                            .foregroundColor(ConcordMaterial.resolvedColor(.featureAccent))
                            .fixedSize(
                                width: platform.deviceType == .desktop ? 56 : 48,
                                height: platform.deviceType == .desktop ? 56 : 48
                            ),
                        ConcordVStack([
                            ConcordText(summary.title).bold(),
                            ConcordText(summary.description)
                        ])
                    ])
                    .fillWidth()
                })

                if let centerAccess {
                    content.append(
                        ConcordAccessButton(access: centerAccess, presentation: .link)
                            .centerJustified()
                    )
                }

                let actions = concordStandardAccessListElements(
                    accessList,
                    platform: platform,
                    centeredOnMobile: centerAccess != nil
                )
                return ConcordPresentation {
                    let workStack = ConcordWorkStack(content, bottom: actions)
                    if platform.deviceType != .desktop {
                        if centerAccess != nil {
                            workStack.bottom.centerJustified()
                        } else {
                            workStack.bottom.leftJustified()
                        }
                    }
                    return workStack
                }
            },
            preferredWindowSize: (width: 640, height: 520),
            dismissAble: true
        )
        return self
    }
}
