//
//  ConcordSummaryData.swift
//  ConcordUI
//
//  Reusable image, title, and description summary content.
//

import Foundation

/// A reusable summary consisting of an image, title, and description.
///
/// Standard feature presentations can use summaries for Get Started content,
/// What's New entries, help topics, and other descriptive lists.
public struct ConcordSummaryData: Sendable, Equatable {
    public let image: ConcordImageData
    public let title: String
    public let description: String

    public init(image: ConcordImageData, title: String, description: String) {
        precondition(!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Summary title must not be empty.")
        precondition(!description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Summary description must not be empty.")
        self.image = image
        self.title = title
        self.description = description
    }
}
