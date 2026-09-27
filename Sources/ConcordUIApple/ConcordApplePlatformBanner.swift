//
//  ConcordApplePlatformBanner.swift
//  ConcordUIApple
//

import ConcordUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private final class ConcordAppleBannerCallbackBox: @unchecked Sendable {
    let callback: ConcordBannerCompletion

    init(_ callback: @escaping ConcordBannerCompletion) {
        self.callback = callback
    }
}

@MainActor private let concordAppleBannerController = ConcordAppleBannerController()

@MainActor
private final class ConcordAppleBannerController: NSObject {
    private var completion: ConcordBannerCompletion?
    private var generation: UInt = 0

    #if canImport(UIKit)
    private weak var overlay: UIView?
    #elseif canImport(AppKit)
    private weak var overlay: NSView?
    #endif

    func show(_ text: String, completion: @escaping ConcordBannerCompletion) {
        dismissCurrent(callCompletion: true)
        generation &+= 1
        let currentGeneration = generation
        self.completion = completion

        #if canImport(UIKit)
        guard let window = activeWindow() else {
            finishCurrent()
            return
        }

        let hostView = window.rootViewController?.view ?? window
        let shield = UIView(frame: hostView.bounds)
        shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shield.backgroundColor = .clear

        let banner = UILabel()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.text = text
        banner.numberOfLines = 0
        banner.textAlignment = .center
        banner.textColor = .label
        banner.backgroundColor = .secondarySystemBackground
        banner.layer.cornerRadius = 10
        banner.layer.masksToBounds = true
        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: 0, y: 80)

        shield.addSubview(banner)
        hostView.addSubview(shield)
        hostView.bringSubviewToFront(shield)
        overlay = shield

        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(greaterThanOrEqualTo: shield.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(lessThanOrEqualTo: shield.trailingAnchor, constant: -20),
            banner.centerXAnchor.constraint(equalTo: shield.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: shield.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            banner.widthAnchor.constraint(lessThanOrEqualToConstant: 560),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        banner.layoutMargins = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        let tap = UITapGestureRecognizer(target: self, action: #selector(userDismissed))
        shield.addGestureRecognizer(tap)

        UIView.animate(withDuration: 0.25) {
            banner.alpha = 1
            banner.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self, self.generation == currentGeneration else { return }
            self.dismissAnimated()
        }

        #elseif canImport(AppKit)
        guard let window = activeMacWindow(),
              let content = window.contentView else {
            finishCurrent()
            return
        }

        // SwiftUI installs NSHostingController.view as the window content view.
        // AppKit explicitly does not support adding arbitrary subviews directly to
        // that hosting view, so install a ConcordUI-owned container as the window's
        // content view and keep the SwiftUI hosting view beneath the banner overlay.
        let overlayHost: NSView
        if let existingHost = content as? ConcordAppleBannerHostView {
            overlayHost = existingHost
        } else {
            let container = ConcordAppleBannerHostView(frame: content.frame)
            container.autoresizingMask = [.width, .height]

            window.contentView = container

            content.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(content)
            NSLayoutConstraint.activate([
                content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                content.topAnchor.constraint(equalTo: container.topAnchor),
                content.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            overlayHost = container
        }

        let shield = ConcordAppleBannerShield(frame: .zero)
        shield.translatesAutoresizingMaskIntoConstraints = false
        shield.controller = self
        shield.wantsLayer = true
        shield.layer?.backgroundColor = NSColor.clear.cgColor

        let banner = NSTextField(wrappingLabelWithString: text)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.alignment = .center
        banner.drawsBackground = true
        banner.backgroundColor = .windowBackgroundColor
        banner.textColor = .labelColor
        banner.wantsLayer = true
        banner.layer?.cornerRadius = 10

        shield.addSubview(banner)
        overlayHost.addSubview(shield, positioned: .above, relativeTo: nil)
        overlay = shield

        NSLayoutConstraint.activate([
            shield.leadingAnchor.constraint(equalTo: overlayHost.leadingAnchor),
            shield.trailingAnchor.constraint(equalTo: overlayHost.trailingAnchor),
            shield.topAnchor.constraint(equalTo: overlayHost.topAnchor),
            shield.bottomAnchor.constraint(equalTo: overlayHost.bottomAnchor),

            banner.leadingAnchor.constraint(greaterThanOrEqualTo: shield.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(lessThanOrEqualTo: shield.trailingAnchor, constant: -20),
            banner.centerXAnchor.constraint(equalTo: shield.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: shield.bottomAnchor, constant: -18),
            banner.widthAnchor.constraint(lessThanOrEqualToConstant: 560),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        banner.alphaValue = 1
        overlayHost.layoutSubtreeIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self, self.generation == currentGeneration else { return }
            self.dismissAnimated()
        }
        #endif
    }

    @objc func userDismissed() {
        dismissAnimated()
    }

    private func dismissAnimated() {
        #if canImport(UIKit)
        guard let overlay else { finishCurrent(); return }
        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
            overlay.transform = CGAffineTransform(translationX: 0, y: 60)
        }, completion: { [weak self] _ in
            overlay.removeFromSuperview()
            self?.finishCurrent()
        })
        #elseif canImport(AppKit)
        guard let overlay else { finishCurrent(); return }
        overlay.removeFromSuperview()
        finishCurrent()
        #else
        finishCurrent()
        #endif
    }

    private func dismissCurrent(callCompletion: Bool) {
        generation &+= 1
        #if canImport(UIKit) || canImport(AppKit)
        overlay?.removeFromSuperview()
        #endif
        if callCompletion {
            finishCurrent()
        } else {
            completion = nil
        }
    }

    private func finishCurrent() {
        let callback = completion
        completion = nil
        overlay = nil
        callback?()
    }

    #if canImport(UIKit)
    private func activeWindow() -> UIWindow? {
        let foregroundScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let foregroundWindows = foregroundScenes.flatMap(\.windows)

        return foregroundWindows.first(where: { window in
            window.isKeyWindow && !window.isHidden && window.alpha > 0
        })
        ?? foregroundWindows.first(where: { window in
            !window.isHidden && window.alpha > 0 && window.windowLevel == .normal
        })
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { !$0.isHidden && $0.alpha > 0 })
    }
    #elseif canImport(AppKit)
    private func activeMacWindow() -> NSWindow? {
        NSApp.keyWindow
        ?? NSApp.mainWindow
        ?? NSApp.orderedWindows.first(where: { $0.isVisible && !$0.isMiniaturized })
    }
    #endif
}

#if canImport(AppKit)
@MainActor
private final class ConcordAppleBannerHostView: NSView {}

@MainActor
private final class ConcordAppleBannerShield: NSView {
    weak var controller: ConcordAppleBannerController?

    override func mouseDown(with event: NSEvent) {
        controller?.userDismissed()
    }
}
#endif

extension ConcordApplePlatform: ConcordPlatformBannerSupport {
    public var canDisplayBanner: Bool { true }

    @discardableResult
    public func banner(
        _ text: String,
        completion: @escaping ConcordBannerCompletion
    ) -> Bool {
        let callbackBox = ConcordAppleBannerCallbackBox(completion)
        Task { @MainActor in
            concordAppleBannerController.show(text) {
                callbackBox.callback()
            }
        }
        return true
    }
}
