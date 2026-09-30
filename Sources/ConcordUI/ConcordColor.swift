//
//  ConcordColor.swift
//  Concord
//
//  Shared portable color contract. Substitute only the project prefix.
//

import Foundation

/// Semantic colors that each native platform resolves using its current appearance/theme.
public enum ConcordSemanticColor: String, Codable, Sendable, Hashable {
    case primary
    case secondary
    case accent
    case background
    case error
    case warning
    case success
}

/// Portable color: explicit RGBA components or a platform-resolved semantic color.
public enum ConcordColor: Codable, Sendable, Hashable {
    case semantic(ConcordSemanticColor)
    case rgba(red: Double, green: Double, blue: Double, alpha: Double)

    public static let primary = ConcordColor.semantic(.primary)
    public static let secondary = ConcordColor.semantic(.secondary)
    public static let accent = ConcordColor.semantic(.accent)
    public static let background = ConcordColor.semantic(.background)
    public static let error = ConcordColor.semantic(.error)
    public static let warning = ConcordColor.semantic(.warning)
    public static let success = ConcordColor.semantic(.success)

    public static let clear = ConcordColor.rgba(red: 0, green: 0, blue: 0, alpha: 0)
    public static let black = ConcordColor.rgba(red: 0, green: 0, blue: 0, alpha: 1)
    public static let white = ConcordColor.rgba(red: 1, green: 1, blue: 1, alpha: 1)
    public static let red = ConcordColor.rgba(red: 1, green: 0, blue: 0, alpha: 1)
    public static let green = ConcordColor.rgba(red: 0, green: 1, blue: 0, alpha: 1)
    public static let blue = ConcordColor.rgba(red: 0, green: 0, blue: 1, alpha: 1)
    public static let gray = ConcordColor.rgba(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

    /// Creates an explicit RGBA color. Component values are clamped to 0...1.
    public static func rgba(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double = 1) -> ConcordColor {
        .rgba(
            red: min(max(red, 0), 1),
            green: min(max(green, 0), 1),
            blue: min(max(blue, 0), 1),
            alpha: min(max(alpha, 0), 1)
        )
    }
}

