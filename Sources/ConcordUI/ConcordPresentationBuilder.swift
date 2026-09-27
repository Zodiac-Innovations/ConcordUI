//
//  ConcordPresentationBuilder.swift
//  ConcordUI
//
//  Deferred construction of a Presentation registered with a Venue.
//

/// Builds a fresh Presentation for a Venue registration using the effective
/// data object selected for that display.
public typealias ConcordPresentationBuilder = ((any ConcordDataProtocol)?) -> ConcordPresentation
