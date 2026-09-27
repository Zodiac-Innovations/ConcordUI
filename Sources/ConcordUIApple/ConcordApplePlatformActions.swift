import ConcordUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension ConcordApplePlatform {
    func canLaunchURL(_ url: URL) -> Bool {
        #if canImport(UIKit)
        return UIApplication.shared.canOpenURL(url)
        #elseif canImport(AppKit)
        return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
        #else
        return false
        #endif
    }

    @discardableResult
    func launchURL(_ url: URL) -> Bool {
        guard canLaunchURL(url) else { return false }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        return true
        #elseif canImport(AppKit)
        return NSWorkspace.shared.open(url)
        #else
        return false
        #endif
    }

    var canComposeEmail: Bool {
        guard let url = URL(string: "mailto:") else { return false }
        return canLaunchURL(url)
    }

    @discardableResult
    func composeEmail(to: [String], subject: String?, body: String?) -> Bool {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to.joined(separator: ",")
        var items: [URLQueryItem] = []
        if let subject, !subject.isEmpty { items.append(URLQueryItem(name: "subject", value: subject)) }
        if let body, !body.isEmpty { items.append(URLQueryItem(name: "body", value: body)) }
        components.queryItems = items.isEmpty ? nil : items
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    var canComposeMessage: Bool {
        #if os(iOS)
        guard let url = URL(string: "sms:") else { return false }
        return canLaunchURL(url)
        #else
        return false
        #endif
    }

    @discardableResult
    func composeMessage(to: [String], body: String?) -> Bool {
        #if os(iOS)
        // Apple's sms URL handoff supports recipients but does not guarantee a body parameter.
        var components = URLComponents()
        components.scheme = "sms"
        components.path = to.joined(separator: ",")
        guard let url = components.url else { return false }
        return launchURL(url)
        #else
        return false
        #endif
    }

    var canDialPhone: Bool {
        #if os(iOS)
        guard let url = URL(string: "tel:") else { return false }
        return canLaunchURL(url)
        #else
        return false
        #endif
    }

    @discardableResult
    func dialPhone(_ number: String) -> Bool {
        #if os(iOS)
        let normalized = number.filter { $0.isNumber || $0 == "+" || $0 == "*" || $0 == "#" }
        guard !normalized.isEmpty, let url = URL(string: "tel:\(normalized)") else { return false }
        return launchURL(url)
        #else
        return false
        #endif
    }

    var canOpenMap: Bool {
        guard let url = URL(string: "https://maps.apple.com/") else { return false }
        return canLaunchURL(url)
    }

    @discardableResult
    func openMap(latitude: Double, longitude: Double, label: String?) -> Bool {
        var components = URLComponents(string: "https://maps.apple.com/")!
        var items = [URLQueryItem(name: "ll", value: "\(latitude),\(longitude)")]
        if let label, !label.isEmpty { items.append(URLQueryItem(name: "q", value: label)) }
        components.queryItems = items
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    @discardableResult
    func openMap(address: String) -> Bool {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [URLQueryItem(name: "address", value: address)]
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    @discardableResult
    func searchMap(_ query: String) -> Bool {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    var canOpenDirections: Bool { canOpenMap }

    @discardableResult
    func openDirections(toLatitude latitude: Double, longitude: Double, label: String?) -> Bool {
        var components = URLComponents(string: "https://maps.apple.com/")!
        var items = [URLQueryItem(name: "daddr", value: "\(latitude),\(longitude)")]
        if let label, !label.isEmpty { items.append(URLQueryItem(name: "q", value: label)) }
        components.queryItems = items
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    @discardableResult
    func openDirections(toAddress address: String) -> Bool {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [URLQueryItem(name: "daddr", value: address)]
        guard let url = components.url else { return false }
        return launchURL(url)
    }

    var canOpenApplicationSettings: Bool {
        #if os(iOS) || os(tvOS) || os(visionOS)
        return true
        #else
        return false
        #endif
    }

    @discardableResult
    func openApplicationSettings() -> Bool {
        #if os(iOS) || os(tvOS) || os(visionOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
        return launchURL(url)
        #else
        return false
        #endif
    }
}


#if canImport(UIKit)
nonisolated(unsafe) private var concordAppleDocumentController: UIDocumentInteractionController?
nonisolated(unsafe) private var concordAppleDocumentDelegate: ConcordAppleDocumentDelegate?

private final class ConcordAppleDocumentDelegate: NSObject, UIDocumentInteractionControllerDelegate {
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func documentInteractionControllerViewControllerForPreview(
        _ controller: UIDocumentInteractionController
    ) -> UIViewController {
        viewController
    }
}
#endif

public extension ConcordApplePlatform {
    func resourceExists(name: String, type: ConcordResourceType) -> Bool {
        resourceURL(name: name, type: type) != nil
    }

    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
        guard let url = resourceURL(name: name, type: type) else { return nil }
        return try? Data(contentsOf: url)
    }

    @discardableResult
    func resourceOpen(name: String, type: ConcordResourceType) -> Bool {
        guard let url = resourceURL(name: name, type: type) else { return false }

        #if canImport(UIKit)
        guard let viewController = concordTopViewController() else { return false }
        let controller = UIDocumentInteractionController(url: url)
        let delegate = ConcordAppleDocumentDelegate(viewController: viewController)
        controller.delegate = delegate
        concordAppleDocumentController = controller
        concordAppleDocumentDelegate = delegate
        return controller.presentPreview(animated: true)
        #elseif canImport(AppKit)
        return NSWorkspace.shared.open(url)
        #else
        return false
        #endif
    }

    private func resourceURL(name: String, type: ConcordResourceType) -> URL? {
        guard isValidResourceName(name) else { return nil }

        for fileExtension in type.fileExtensions {
            if let url = Bundle.main.url(
                forResource: name,
                withExtension: fileExtension,
                subdirectory: "Files"
            ) {
                return url
            }
        }
        return nil
    }

    private func isValidResourceName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !trimmed.contains("/") && !trimmed.contains("\\")
    }

    #if canImport(UIKit)
    private func concordTopViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        var current = root
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }
    #endif
}
