//
//  ConcordPDFData.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/29/26.
//
//  Defines portable PDF document data.
//

import Foundation

/// Platform-independent encoded PDF document data.
///
/// Additional PDF metadata can be added without exposing platform-specific PDF types.
public struct ConcordPDFData: Codable, Sendable {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}
