//
//  ConcordFAQFeature.swift
//  ConcordUI
//
//  Standard FAQ feature behavior and presentation.
//

/// Creates a text-and-icon button that invokes the application's FAQ feature.
/// The configured title is used as the button's accessibility label.

/// Installs the standard FAQ Presentation.
public extension ConcordApplication {
    /// Creates a button that invokes this application's configured feature.
    /// The supplied title overrides the feature title and is retained for accessibility.
    func concordFAQFeatureButton(
        title: String? = nil,
        flavor: ConcordButtonFlavor = .textIcon
    ) -> ConcordButton {
        let resolvedTitle = title ?? faqFeature?.title
            ?? ConcordString.faqTitle(platform.appName)
        return ConcordButton(
            resolvedTitle,
            flavor: flavor,
            icon: .faq
        ) { [weak self] in
            self?.showFAQFeature()
        }
    }


    /// Installs the standard FAQ Presentation from inline JSON text.
    @discardableResult
    func useStandardFAQFeature(
        title: String? = nil,
        text: String,
        accessList: [ConcordAccessData] = []
    ) -> Self {
        let data = try! ConcordFAQFeatureData(json: text)
        return useStandardFAQFeature(
            title: title,
            data: data,
            accessList: accessList
        )
    }

    /// Installs the standard FAQ Presentation from a bundled text resource.
    @discardableResult
    func useStandardFAQFeature(
        title: String? = nil,
        file: String,
        accessList: [ConcordAccessData] = []
    ) -> Self {
        guard let text = platform.textRetrieve(name: file) else {
            preconditionFailure("Unable to read FAQ text resource '\(file)'.")
        }
        return useStandardFAQFeature(
            title: title,
            text: text,
            accessList: accessList
        )
    }

    @discardableResult
    func useStandardFAQFeature(
        title: String? = nil,
        data: ConcordFAQFeatureData,
        accessList: [ConcordAccessData] = []
    ) -> Self {
        let platform = self.platform
        let resolvedTitle = title ?? ConcordString.faqTitle(platform.appName)
        faqFeature = ConcordFeatureConfig(
            title: resolvedTitle,
            presentation: {
                var content: [ConcordElement] = []

                for list in data.sections {
                    if !list.title.isEmpty {
                        content.append(
                            ConcordText(list.title)
                                .bold()
                                .fontSize(platform.deviceType == .desktop ? 24 : 21)
                        )
                    }

                    for item in list.questions {
                        var answer: [ConcordElement] = [
                            ConcordText("\(ConcordString.answerPrefix) \(item.answer)")
                        ]
                        answer.append(contentsOf: item.access.map {
                            ConcordAccessButton(access: $0, presentation: .link)
                        })

                        content.append(
                            ConcordExpander(
                                .triangle,
                                label: "\(ConcordString.questionPrefix) \(item.question)",
                                elements: answer,
                                onRight: false
                            )
                            .bold()
                        )
                    }
                }

                let actions = concordStandardAccessListElements(accessList, platform: platform)
                return ConcordPresentation {
                    let workStack = ConcordWorkStack(content, bottom: actions)
                    workStack.main.edge(platform.deviceType == .desktop ? 20 : 0)
                    if platform.deviceType != .desktop {
                        workStack.bottom.leftJustified()
                    }
                    return workStack
                }
            },
            preferredWindowSize: (width: 640, height: 600),
            dismissAble: true
        )
        return self
    }
}
