//
//  ConcordPDF.swift
//  ConcordUI
//
//  Defines portable PDF document data.
//

import Foundation

/// Platform-independent PDF document data.
public struct ConcordPDF: Codable, Sendable {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}
