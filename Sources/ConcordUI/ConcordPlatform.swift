//
//  ConcordPlatform.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/15/26.
//
//  Defines the platform abstraction supplied to ConcordUI applications.
//

import Foundation

// MARK: - Platform

/// Platform-specific services available to a ConcordUI application.
public protocol ConcordPlatform: AnyObject {
    var appIcon: ConcordImageData { get }
    func concordImage() -> ConcordImageData
    func concordUIAltImage() -> ConcordImageData
    var appName: String { get }
    var appIdentifier: String { get }
    var appCopyright: String? { get }
    var appVersion: String { get }
    var appBuild: String { get }
    var platformName: String { get }
    var platformVersion: String { get }
    var platformAPILevel: Int? { get }
    var deviceModel: String { get }
    var deviceManufacturer: String { get }
    var localeIdentifier: String { get }
    var languageCode: String { get }
    var timeZoneIdentifier: String { get }
    var appearanceMode: String { get }
    var deviceClass: String { get }
    var platformType: ConcordPlatformType { get }
    var deviceType: ConcordDeviceType { get }
    var orientation: ConcordOrientation { get }

    // MARK: External platform actions

    func canLaunchURL(_ url: URL) -> Bool
    @discardableResult func launchURL(_ url: URL) -> Bool

    var canComposeEmail: Bool { get }
    @discardableResult func composeEmail(to: [String], subject: String?, body: String?) -> Bool

    var canComposeMessage: Bool { get }
    @discardableResult func composeMessage(to: [String], body: String?) -> Bool

    var canDialPhone: Bool { get }
    @discardableResult func dialPhone(_ number: String) -> Bool

    var canOpenMap: Bool { get }
    @discardableResult func openMap(latitude: Double, longitude: Double, label: String?) -> Bool
    @discardableResult func openMap(address: String) -> Bool
    @discardableResult func searchMap(_ query: String) -> Bool

    var canOpenDirections: Bool { get }
    @discardableResult func openDirections(toLatitude latitude: Double, longitude: Double, label: String?) -> Bool
    @discardableResult func openDirections(toAddress address: String) -> Bool

    var canOpenApplicationSettings: Bool { get }
    @discardableResult func openApplicationSettings() -> Bool

    // MARK: Embedded resources

    func resourceExists(name: String, type: ConcordResourceType) -> Bool
    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data?
    @discardableResult func resourceOpen(name: String, type: ConcordResourceType) -> Bool

    // MARK: Persistent storage

    @discardableResult func setPersistentData(_ data: Data, forKey key: String) -> Bool
    func persistentData(forKey key: String) -> Data?
    @discardableResult func removePersistentValue(forKey key: String) -> Bool

    // MARK: Secure storage

    @discardableResult func setSecureData(_ data: Data, forKey key: String) -> Bool
    func secureData(forKey key: String) -> Data?
    @discardableResult func removeSecureValue(forKey key: String) -> Bool

    /// Legacy root-host rendering entry point retained while platform backends migrate
    /// to Venue-aware hosting.
    func displayPresentation(_ presentation: ConcordPresentation)
    func refreshPresentation(_ presentation: ConcordPresentation)

    /// Venue-aware rendering entry point. New platform hosting code should implement
    /// this overload when Main, Auxiliary, and Modal Venues need distinct native hosts.
    func displayPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue)
    func refreshPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue)
}

public extension ConcordPlatform {
    var appIcon: ConcordImageData { .icon(.app) }
    func concordImage() -> ConcordImageData { .asset("concordui-1024") }
    func concordUIAltImage() -> ConcordImageData { .asset("concordui-alt-256") }
    var appName: String { ConcordString.application }
    var appIdentifier: String { "" }
    var appCopyright: String? { nil }
    var appVersion: String { "0.0" }
    var appBuild: String { "0" }
    var platformName: String { ConcordString.unknown }
    var platformVersion: String { ConcordString.unknown }
    var platformAPILevel: Int? { nil }
    var deviceModel: String { ConcordString.unknown }
    var deviceManufacturer: String { ConcordString.unknown }
    var localeIdentifier: String { ConcordString.unknown }
    var languageCode: String { ConcordString.unknown }
    var timeZoneIdentifier: String { ConcordString.unknown }
    var appearanceMode: String { ConcordString.unknown }
    var deviceClass: String { ConcordString.unknown }
    var platformType: ConcordPlatformType { .unknown }
    var deviceType: ConcordDeviceType { .unknown }
    var orientation: ConcordOrientation { .none }

    var appVersionBuild: String { ConcordString.versionBuild(version: appVersion, build: appBuild) }

    // MARK: Venue-aware presentation defaults

    /// Compatibility bridge for platform backends that still have a single root host.
    /// Main Venue behavior is therefore unchanged while Auxiliary/Modal native host
    /// support can be added platform-by-platform without changing the Core API again.
    func displayPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        displayPresentation(presentation)
    }

    func refreshPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        refreshPresentation(presentation)
    }

    // MARK: External platform action defaults

    func canLaunchURL(_ url: URL) -> Bool { false }
    @discardableResult func launchURL(_ url: URL) -> Bool { false }

    var canComposeEmail: Bool { false }
    @discardableResult func composeEmail(to: [String], subject: String? = nil, body: String? = nil) -> Bool { false }

    var canComposeMessage: Bool { false }
    @discardableResult func composeMessage(to: [String], body: String? = nil) -> Bool { false }

    var canDialPhone: Bool { false }
    @discardableResult func dialPhone(_ number: String) -> Bool { false }

    var canOpenMap: Bool { false }
    @discardableResult func openMap(latitude: Double, longitude: Double, label: String? = nil) -> Bool { false }
    @discardableResult func openMap(address: String) -> Bool { false }
    @discardableResult func searchMap(_ query: String) -> Bool { false }

    var canOpenDirections: Bool { false }
    @discardableResult func openDirections(toLatitude latitude: Double, longitude: Double, label: String? = nil) -> Bool { false }
    @discardableResult func openDirections(toAddress address: String) -> Bool { false }

    var canOpenApplicationSettings: Bool { false }
    @discardableResult func openApplicationSettings() -> Bool { false }

    // MARK: Embedded resource defaults and conveniences

    func resourceExists(name: String, type: ConcordResourceType) -> Bool { false }
    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? { nil }
    @discardableResult func resourceOpen(name: String, type: ConcordResourceType) -> Bool { false }

    func textExists(name: String) -> Bool {
        resourceExists(name: name, type: .text)
    }

    func textRetrieve(name: String) -> String? {
        guard let data = resourceRetrieve(name: name, type: .text) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func textOpen(name: String) -> Bool {
        resourceOpen(name: name, type: .text)
    }

    func pdfExists(name: String) -> Bool {
        resourceExists(name: name, type: .pdf)
    }

    func pdfRetrieve(name: String) -> Data? {
        resourceRetrieve(name: name, type: .pdf)
    }

    @discardableResult
    func pdfOpen(name: String) -> Bool {
        resourceOpen(name: name, type: .pdf)
    }

    func imageExists(name: String) -> Bool {
        resourceExists(name: name, type: .image)
    }

    func imageRetrieve(name: String) -> Data? {
        resourceRetrieve(name: name, type: .image)
    }

    @discardableResult
    func imageOpen(name: String) -> Bool {
        resourceOpen(name: name, type: .image)
    }

    // MARK: Persistent storage defaults

    @discardableResult
    func setPersistentData(_ data: Data, forKey key: String) -> Bool {
        UserDefaults.standard.set(data, forKey: key)
        return true
    }

    func persistentData(forKey key: String) -> Data? {
        UserDefaults.standard.data(forKey: key)
    }

    @discardableResult
    func removePersistentValue(forKey key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return true
    }

    @discardableResult
    func setPersistentString(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return setPersistentData(data, forKey: key)
    }

    func persistentString(forKey key: String) -> String? {
        guard let data = persistentData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // Compatibility conveniences used by application launch tracking.
    func permanentIntegerRetrieve(key: String) -> Int? {
        guard let text = persistentString(forKey: key) else { return nil }
        return Int(text)
    }

    @discardableResult
    func permanentIntegerStore(key: String, value: Int) -> Bool {
        setPersistentString(String(value), forKey: key)
    }

    func permanentStringRetrieve(key: String) -> String? {
        persistentString(forKey: key)
    }

    @discardableResult
    func permanentStringStore(key: String, value: String) -> Bool {
        setPersistentString(value, forKey: key)
    }

    // MARK: Secure storage conveniences/defaults

    @discardableResult
    func setSecureString(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return setSecureData(data, forKey: key)
    }

    func secureString(forKey key: String) -> String? {
        guard let data = secureData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult func setSecureData(_ data: Data, forKey key: String) -> Bool { false }
    func secureData(forKey key: String) -> Data? { nil }
    @discardableResult func removeSecureValue(forKey key: String) -> Bool { false }
}
