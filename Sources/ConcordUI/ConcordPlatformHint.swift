//
//  ConcordPlatformHint.swift
//  ConcordUI
//
//  Portable escape hatch for element-specific native rendering hints.
//

/// Platforms that may consume ConcordUI element hints.
public enum ConcordPlatformType: String, CaseIterable, Sendable, Hashable {
    case iOS
    case android
    case macOS
    case windows
    case unknown
}

/// Broad physical device category reported by a ConcordUI platform backend.
public enum ConcordDeviceType: String, CaseIterable, Sendable, Hashable {
    case mobile
    case pad
    case desktop
    case unknown
}

/// Rotation state for a device. Desktop platforms report `none`.
public enum ConcordOrientation: String, CaseIterable, Sendable, Hashable {
    case landscape
    case portrait
    case none
}

/// A low-level, platform-specific instruction attached to an element.
///
/// ConcordUI deliberately leaves `number` and `param` uninterpreted. Their
/// meanings are defined by the concrete element and its platform renderer.
public struct ConcordPlatformHint: Sendable, Equatable, Hashable {
    public let platform: ConcordPlatformType
    public let number: Int
    public let param: Int?

    public init(
        platform: ConcordPlatformType,
        number: Int,
        param: Int? = nil
    ) {
        self.platform = platform
        self.number = number
        self.param = param
    }
}
