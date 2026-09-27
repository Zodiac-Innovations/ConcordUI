//
//  ConcordAboutFeature.swift
//  ConcordUI
//
//  Application-level About behavior.
//

/// Creates a text-and-icon button that invokes the application's About feature.
/// The title is also used as the button's accessibility label.

/// Installs the standard About Presentation with optional document links.
public extension ConcordApplication {
    /// Creates a button that invokes this application's configured feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordAboutFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? aboutFeature?.title ?? ConcordString.aboutTitle(platform.appName)
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .information
        ) { [weak self] in
            self?.showAboutFeature()
        }
    }


    /// Installs the common About Presentation using conventional acknowledgements
    /// and license-agreement website links when supplied.
    @discardableResult
    func useStandardAboutFeature(
        urlAcknowledgements: String?,
        urlLicenseAgreement: String?
    ) -> Self {
        var accessList: [ConcordAccessData] = []
        if let urlAcknowledgements {
            accessList.append(
                ConcordAccessData(title: ConcordString.acknowledgements, link: urlAcknowledgements)
            )
        }
        if let urlLicenseAgreement {
            accessList.append(
                ConcordAccessData(title: ConcordString.licenseAgreement, link: urlLicenseAgreement)
            )
        }
        return useStandardAboutFeature(accessList: accessList)
    }

    @discardableResult
    func useStandardAboutFeature(accessList: [ConcordAccessData] = []) -> Self {
        let platform = self.platform
        aboutFeature = ConcordFeatureConfig(
            title: nil,
            presentation: {
                ConcordPresentation {
                    let appIcon = ConcordImage(platform.appIcon)
                        .fillSquare()
                        .fillWidth()
                    var details: [ConcordElement] = [
                        ConcordImage(platform.concordUIAltImage())
                            .fixedSize(
                                width: platform.deviceType == .desktop ? 56 : 48,
                                height: platform.deviceType == .desktop ? 56 : 48
                            ),
                        ConcordText(platform.appName).bold().fontSize(20),
                        ConcordText(platform.appVersionBuild),
                        ConcordSpacer()
                    ]
                    if let copyright = platform.appCopyright, !copyright.isEmpty {
                        details.append(ConcordText(copyright))
                    }

                    let identity = ConcordABStack(
                        a: ConcordVStack([appIcon])
                            .edge(platform.deviceType == .desktop ? 0 : ConcordContainer.defaultEdge),
                        b: ConcordVStack(details),
                        aFraction: 0.4
                    )
                    .edge(platform.deviceType == .desktop ? 4 : ConcordContainer.defaultEdge)
                    let actions = concordStandardAccessListElements(accessList, platform: platform)
                    let workStack = ConcordWorkStack([identity], bottom: actions)
                    if platform.deviceType != .desktop {
                        workStack.bottom.leftJustified()
                    }
                    return workStack
                }
            },
            preferredWindowSize: (width: 576, height: 354),
            dismissAble: true
        )
        return self
    }
}
