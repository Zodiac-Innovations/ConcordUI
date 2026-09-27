//
//  ConcordResource.swift
//  ConcordUI
//
//  Defines portable embedded-resource types.
//

import Foundation

/// The kind of embedded application resource to locate.
///
/// Resource names are logical names without a directory or filename extension.
public enum ConcordResourceType: Sendable, Equatable {
    case text
    case pdf
    case image
    case custom(String)

    /// Filename extensions searched for this resource type, in priority order.
    public var fileExtensions: [String] {
        switch self {
        case .text:
            return ["txt", "text"]
        case .pdf:
            return ["pdf"]
        case .image:
            return ["png", "jpeg", "jpg", "avif"]
        case .custom(let value):
            let normalized = value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "."))
                .lowercased()
            return normalized.isEmpty ? [] : [normalized]
        }
    }
}
