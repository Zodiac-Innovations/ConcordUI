import ConcordUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
nonisolated(unsafe) private var concordAppleSharingPicker: NSSharingServicePicker?
#endif

extension ConcordApplePlatform: ConcordPlatformFileSupport {
    public var canRetrieveResources: Bool { true }
    public var canOpenResources: Bool { true }

    public var canShareResources: Bool {
        #if canImport(UIKit) || canImport(AppKit)
        return true
        #else
        return false
        #endif
    }

    @discardableResult
    public func resourceShare(name: String, type: ConcordResourceType) -> Bool {
        guard let url = sharingResourceURL(name: name, type: type) else { return false }
        return presentShareItems([url])
    }

    @discardableResult
    public func shareTextContent(_ text: String) -> Bool {
        presentShareItems([text])
    }

    @discardableResult
    public func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool {
        guard let url = temporaryShareURL(filename: filename) else { return false }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
            return presentShareItems([url])
        } catch {
            return false
        }
    }

    private func sharingResourceURL(name: String, type: ConcordResourceType) -> URL? {
        guard validSharingResourceName(name) else { return nil }

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

    private func temporaryShareURL(filename: String) -> URL? {
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.contains("/"),
              !trimmed.contains("\\") else { return nil }
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("ConcordUI-Share", isDirectory: true)
            .appendingPathComponent(trimmed, isDirectory: false)
    }

    private func validSharingResourceName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !trimmed.contains("/") && !trimmed.contains("\\")
    }

    @discardableResult
    private func presentShareItems(_ items: sending [Any]) -> Bool {
        #if canImport(UIKit)
        guard let viewController = sharingTopViewController() else { return false }
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 1,
                height: 1
            )
        }
        viewController.present(controller, animated: true)
        return true
        #elseif canImport(AppKit)
        guard let view = NSApp.keyWindow?.contentView ?? NSApp.mainWindow?.contentView else { return false }
        let picker = NSSharingServicePicker(items: items)
        concordAppleSharingPicker = picker
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        return true
        #else
        return false
        #endif
    }

    #if canImport(UIKit)
    private func sharingTopViewController() -> UIViewController? {
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
