//
//  ConcordAccessData.swift
//  ConcordUI
//
//  User-readable links and bundled documents.
//

import Foundation

/// A titled reference to either a URL or a bundled application file.
public struct ConcordAccessData: Codable, Sendable, Equatable {
    public let title: String
    public let link: String?
    public let file: String?

    public init(title: String, link: String? = nil, file: String? = nil) {
        precondition(!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Access title must not be empty.")
        let hasLink = link.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? false
        let hasFile = file.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? false
        precondition(hasLink != hasFile, "Access requires exactly one link or file.")
        self.title = title
        self.link = link
        self.file = file
    }

    /// Opens the reference using the application's platform services.
    /// Returns false when the destination cannot be opened.
    @discardableResult
    public func openAccess(using application: ConcordApplication) -> Bool {
        if let link {
            guard let url = URL(string: link), url.scheme != nil else { return false }
            return application.platform.launchURL(url)
        }
        guard let file else { return false }
        return application.platform.openDataFile(file)
    }
}

/// Native presentations for an access action.
public enum ConcordAccessPresentation: Sendable, Equatable {
    /// A conventional action button, normally placed in a WorkStack footer.
    case button

    /// An accent-colored, unfilled link placed within presentation content.
    case link
}

/// A native control that opens the supplied access reference in its application's context.
public final class ConcordAccessButton: ConcordButton {
    public let access: ConcordAccessData
    public let presentation: ConcordAccessPresentation

    public init(
        access: ConcordAccessData,
        presentation: ConcordAccessPresentation = .button
    ) {
        self.access = access
        self.presentation = presentation
        super.init(access.title, flavor: .text, action: { event in
            guard let application = (event.element.actionDispatcher as? ConcordVenue)?.application else {
                return
            }
            access.openAccess(using: application)
        })
        if presentation == .link {
            foregroundColor = ConcordMaterial.resolvedColor(.accessAccent)
        }
    }
}


/// Builds standard feature-footer access buttons, centering nonempty lists on
/// mobile and tablet layouts with equal flexible space on both sides.
internal func concordStandardAccessListElements(
    _ accessList: [ConcordAccessData],
    platform: any ConcordPlatform,
    centeredOnMobile: Bool = false
) -> [ConcordElement] {
    let buttons: [ConcordElement] = accessList.map { ConcordAccessButton(access: $0) }
    guard platform.deviceType != .desktop, centeredOnMobile, !buttons.isEmpty else { return buttons }
    var centered: [ConcordElement] = [ConcordSpacer()]
    centered.append(contentsOf: buttons)
    centered.append(ConcordSpacer())
    return centered
}
