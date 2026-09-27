//
//  ConcordContainer.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/16/26.
//

import Foundation

/// Base class for elements that contain an ordered collection of child elements.
open class ConcordContainer: ConcordElement {
    public static let defaultEdge: Double = 10
    public static let defaultSpacing: Double = 8

    public var elements: [ConcordElement]
    public var edge: Double
    public var spacing: Double

    /// Creates a container with its essential child collection.
    public init(_ elements: [ConcordElement] = []) {
        self.elements = elements
        self.edge = ConcordContainer.defaultEdge
        self.spacing = ConcordContainer.defaultSpacing
        super.init()
    }

    public func add(_ element: ConcordElement) { elements.append(element) }
    public func remove(id: UUID) { elements.removeAll { $0.id == id } }
    public func removeAll() { elements.removeAll() }
}
