//
//  ConcordPlatformBannerServices.swift
//  ConcordUI
//
//  Transient platform-wide banner messages.
//

import Foundation

public typealias ConcordBannerCompletion = () -> Void

/// Optional platform support for transient application-wide banner messages.
/// A banner remains visible until its native timeout expires or the user acknowledges it by touching the screen.
public protocol ConcordPlatformBannerSupport: AnyObject {
    var canDisplayBanner: Bool { get }

    @discardableResult
    func banner(
        _ text: String,
        completion: @escaping ConcordBannerCompletion
    ) -> Bool
}

public extension ConcordPlatform {
    private var bannerSupport: (any ConcordPlatformBannerSupport)? {
        self as? any ConcordPlatformBannerSupport
    }

    var canDisplayBanner: Bool {
        bannerSupport?.canDisplayBanner ?? false
    }

    /// Displays a transient platform-wide banner message.
    @discardableResult
    func banner(
        _ text: String,
        completion: @escaping ConcordBannerCompletion = {}
    ) -> Bool {
        let message = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty, let support = bannerSupport, support.canDisplayBanner else { return false }
        return support.banner(message, completion: completion)
    }

    /// Displays multiple banner messages sequentially.
    @discardableResult
    func bannerList(
        _ messages: [String],
        completion: @escaping ConcordBannerCompletion = {}
    ) -> Bool {
        guard let support = bannerSupport, support.canDisplayBanner else { return false }

        let remaining = messages.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !remaining.isEmpty else {
            completion()
            return false
        }

        func display(_ messages: ArraySlice<String>) -> Bool {
            guard let message = messages.first else {
                completion()
                return true
            }

            return support.banner(message) {
                let rest = messages.dropFirst()
                if rest.isEmpty {
                    completion()
                } else {
                    _ = display(rest)
                }
            }
        }

        return display(remaining[...])
    }
}
