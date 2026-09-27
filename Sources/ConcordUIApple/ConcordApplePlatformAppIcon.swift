import ConcordUI
import Foundation
#if canImport(Darwin)
import Darwin
#endif
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension ConcordApplePlatform {
    /// Returns the application's primary icon using the icon resources generated
    /// into the main bundle by the Apple platform. If the application icon
    /// cannot be resolved, ConcordUI falls back to the platform's semantic app
    /// icon rather than returning an optional value.
    var appIcon: ConcordImageData {
        let bundle = Bundle.main
        var candidateNames: [String] = []

        #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        if let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any] {
            if let files = primary["CFBundleIconFiles"] as? [String] {
                candidateNames.append(contentsOf: files.reversed())
            }
            if let name = primary["CFBundleIconName"] as? String {
                candidateNames.append(name)
            }
        }

        if let files = bundle.object(forInfoDictionaryKey: "CFBundleIconFiles") as? [String] {
            candidateNames.append(contentsOf: files.reversed())
        }
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleIconName") as? String {
            candidateNames.append(name)
        }
        #elseif os(macOS)
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleIconName") as? String {
            candidateNames.append(name)
        }
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
            candidateNames.append(name)
        }
        #endif

        #if os(macOS)
        if let candidate = candidateNames.first(where: { !$0.isEmpty }) {
            return .asset(candidate)
        }
        #else
        for candidate in candidateNames where !candidate.isEmpty {
            if bundleContainsImage(named: candidate, in: bundle) {
                return .asset(candidate)
            }
        }
        #endif

        if let urls = bundle.urls(forResourcesWithExtension: "png", subdirectory: nil) {
            let iconURLs = urls.filter {
                let name = $0.deletingPathExtension().lastPathComponent.lowercased()
                return name.contains("appicon") || name.contains("app-icon")
            }
            let sorted = iconURLs.sorted { fileSize($0) > fileSize($1) }
            if let url = sorted.first {
                return .asset(url.lastPathComponent)
            }
        }

        return .icon(.app)
    }

    /// Apple user-facing display name, falling back to the bundle name.
    var appName: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? ConcordString.application
    }

    /// Apple bundle identifier.
    var appIdentifier: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    /// Apple human-readable copyright (`NSHumanReadableCopyright`).
    var appCopyright: String? {
        Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    }

    /// Apple bundle short version string (`CFBundleShortVersionString`).
    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.0"
    }

    /// Apple bundle build string (`CFBundleVersion`).
    var appBuild: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "0"
    }

    /// ConcordUI name for the running Apple operating-system family.
    var platformName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Apple"
        #endif
    }

    /// Strongly typed ConcordUI platform family.
    var platformType: ConcordPlatformType {
        #if os(macOS)
        return .macOS
        #elseif os(iOS)
        return .iOS
        #else
        return .unknown
        #endif
    }

    /// Apple operating-system version reported by Foundation.
    var platformVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    /// Apple does not expose an Android-style integer API level.
    var platformAPILevel: Int? { nil }

    /// Hardware/model identifier for the current Apple device.
    var deviceModel: String {
        #if os(macOS)
        return hardwareIdentifier(named: "hw.model")
        #else
        return hardwareIdentifier(named: "hw.machine")
        #endif
    }

    /// Manufacturer for Apple devices.
    var deviceManufacturer: String { "Apple" }

    /// Foundation locale identifier for the current environment.
    var localeIdentifier: String { Locale.current.identifier }

    /// First preferred language configured by the user.
    var languageCode: String { Locale.preferredLanguages.first ?? ConcordString.unknown }

    /// Foundation time-zone identifier for the current environment.
    var timeZoneIdentifier: String { TimeZone.current.identifier }

    /// Current Apple appearance mode when it can be determined.
    var appearanceMode: String {
        #if canImport(UIKit)
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            return "dark"
        case .light:
            return "light"
        default:
            return "unspecified"
        }
        #elseif os(macOS)
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
            ? "dark"
            : "light"
        #else
        return "unspecified"
        #endif
    }

    /// Broad ConcordUI device class for the current Apple environment.
    var deviceClass: String {
        #if os(macOS)
        return "desktop"
        #elseif os(tvOS)
        return "TV"
        #elseif os(watchOS)
        return "watch"
        #elseif os(visionOS)
        return "headset"
        #elseif canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "phone"
        case .pad:
            return "tablet"
        case .tv:
            return "TV"
        case .carPlay:
            return "car"
        case .mac:
            return "desktop"
        default:
            return "device"
        }
        #else
        return "device"
        #endif
    }

    /// Strongly typed ConcordUI device category.
    var deviceType: ConcordDeviceType {
        #if os(macOS)
        return .desktop
        #elseif os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return .mobile
        case .pad: return .pad
        case .mac: return .desktop
        default: return .unknown
        }
        #else
        return .unknown
        #endif
    }

    /// Current device rotation. Desktop platforms do not rotate.
    var orientation: ConcordOrientation {
        #if os(iOS)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight: return .landscape
        case .portrait, .portraitUpsideDown: return .portrait
        default:
            let bounds = UIScreen.main.bounds
            return bounds.width > bounds.height ? .landscape : .portrait
        }
        #else
        return .none
        #endif
    }

    private func bundleContainsImage(named name: String, in bundle: Bundle) -> Bool {
        let nsName = name as NSString
        let base = nsName.deletingPathExtension
        let ext = nsName.pathExtension

        if !ext.isEmpty, bundle.url(forResource: base, withExtension: ext) != nil {
            return true
        }

        for fileExtension in ["png", "jpg", "jpeg"] {
            if bundle.url(forResource: name, withExtension: fileExtension) != nil {
                return true
            }
        }

        return false
    }

    private func fileSize(_ url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values?.fileSize ?? 0)
    }

    private func hardwareIdentifier(named key: String) -> String {
        #if canImport(Darwin)
        var size: size_t = 0
        guard sysctlbyname(key, nil, &size, nil, 0) == 0, size > 0 else {
            return ConcordString.unknown
        }

        var value = [CChar](repeating: 0, count: size)
        guard sysctlbyname(key, &value, &size, nil, 0) == 0 else {
            return ConcordString.unknown
        }

        return String(cString: value)
        #else
        return ConcordString.unknown
        #endif
    }
}
