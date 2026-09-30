//
//  ConcordVector.swift
//  Concord
//
//  Platform-independent vector drawing definitions.
//  Keep this contract identical across projects after substituting the project prefix.
//

import Foundation

// MARK: - Geometry

/// A point in a vector drawing's local coordinate system.
public struct ConcordPoint: Codable, Sendable, Equatable {
    public var x: ConcordFloat
    public var y: ConcordFloat

    public init(x: ConcordFloat, y: ConcordFloat) {
        self.x = x
        self.y = y
    }
}

/// A size in a vector drawing's local coordinate system.
public struct ConcordSize: Codable, Sendable, Equatable {
    public var width: ConcordFloat
    public var height: ConcordFloat

    public init(width: ConcordFloat, height: ConcordFloat) {
        self.width = width
        self.height = height
    }
}

/// A rectangle in a vector drawing's local coordinate system.
public struct ConcordRect: Codable, Sendable, Equatable {
    public var origin: ConcordPoint
    public var size: ConcordSize

    public init(origin: ConcordPoint, size: ConcordSize) {
        self.origin = origin
        self.size = size
    }

    public init(x: ConcordFloat, y: ConcordFloat, width: ConcordFloat, height: ConcordFloat) {
        self.init(origin: ConcordPoint(x: x, y: y), size: ConcordSize(width: width, height: height))
    }
}

// MARK: - Stroke and Fill

public enum ConcordVectorLineCap: String, Codable, Sendable, Equatable {
    case butt
    case round
    case square
}

public enum ConcordVectorLineJoin: String, Codable, Sendable, Equatable {
    case miter
    case round
    case bevel
}

public enum ConcordVectorLinePattern: Codable, Sendable, Equatable {
    case solid
    case dashed(lengths: [ConcordFloat], phase: ConcordFloat = 0)
}

public struct ConcordVectorStroke: Codable, Sendable, Equatable {
    public var material: ConcordMaterial
    public var thickness: ConcordFloat
    public var pattern: ConcordVectorLinePattern
    public var cap: ConcordVectorLineCap
    public var join: ConcordVectorLineJoin

    public init(
        material: ConcordMaterial = .black,
        thickness: ConcordFloat = 1,
        pattern: ConcordVectorLinePattern = .solid,
        cap: ConcordVectorLineCap = .butt,
        join: ConcordVectorLineJoin = .miter
    ) {
        self.material = material
        self.thickness = max(0, thickness)
        self.pattern = pattern
        self.cap = cap
        self.join = join
    }

    public init(
        color: ConcordColor,
        thickness: ConcordFloat = 1,
        pattern: ConcordVectorLinePattern = .solid,
        cap: ConcordVectorLineCap = .butt,
        join: ConcordVectorLineJoin = .miter
    ) {
        self.init(
            material: .color(color),
            thickness: thickness,
            pattern: pattern,
            cap: cap,
            join: join
        )
    }
}

public enum ConcordVectorFillPattern: Codable, Sendable, Equatable {
    case material(ConcordMaterial)
    case solid(ConcordColor)
}

public struct ConcordVectorFill: Codable, Sendable, Equatable {
    public var pattern: ConcordVectorFillPattern

    public init(pattern: ConcordVectorFillPattern) {
        self.pattern = pattern
    }

    public init(material: ConcordMaterial) {
        self.pattern = .material(material)
    }

    public init(color: ConcordColor) {
        self.pattern = .material(.color(color))
    }
}

// MARK: - Drawing Behavior

public enum ConcordVectorArcDirection: String, Codable, Sendable, Equatable {
    case clockwise
    case counterclockwise
}

public enum ConcordVectorContentMode: String, Codable, Sendable, Equatable {
    case fit
    case fill
    case stretch
    case original
}

public enum ConcordVectorAlignment: String, Codable, Sendable, Equatable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing
}

/// Issues platform-independent drawing commands in a local coordinate system.
/// The origin is at the upper-left, positive x extends right, and positive y extends down.
public protocol ConcordVectorDrawingProtocol: AnyObject {
    /// The logical bounds visible to drawing commands, independent of physical output size.
    var bounds: ConcordRect { get }

    func drawLine(from start: ConcordPoint, to end: ConcordPoint, stroke: ConcordVectorStroke)
    func drawRectangle(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?)
    func drawRoundedRectangle(
        in rect: ConcordRect,
        cornerRadius: ConcordFloat,
        stroke: ConcordVectorStroke?,
        fill: ConcordVectorFill?
    )
    func drawOval(in rect: ConcordRect, stroke: ConcordVectorStroke?, fill: ConcordVectorFill?)

    /// Draws an arc whose zero-degree angle points right. Positive angles follow the clockwise
    /// direction of the local coordinate system unless `direction` specifies otherwise.
    func drawArc(
        center: ConcordPoint,
        radius: ConcordFloat,
        startAngle: ConcordFloat,
        endAngle: ConcordFloat,
        direction: ConcordVectorArcDirection,
        stroke: ConcordVectorStroke
    )

    func drawPolygon(
        points: [ConcordPoint],
        stroke: ConcordVectorStroke?,
        fill: ConcordVectorFill?
    )
    func drawQuadraticBezier(
        from start: ConcordPoint,
        control: ConcordPoint,
        to end: ConcordPoint,
        stroke: ConcordVectorStroke
    )
    func drawCubicBezier(
        from start: ConcordPoint,
        control1: ConcordPoint,
        control2: ConcordPoint,
        to end: ConcordPoint,
        stroke: ConcordVectorStroke
    )

    /// Draws bitmap data, optionally cropping it with `sourceRect`, into `destinationRect`.
    func drawBitmap(
        data: Data,
        sourceRect: ConcordRect?,
        destinationRect: ConcordRect,
        opacity: ConcordFloat
    )

    /// Offers opaque developer-defined data to a specialized drawer.
    /// Returns true when the drawer recognizes and handles the command.
    @discardableResult
    func drawSpecialData(type: String, data: String) -> Bool
}

public extension ConcordVectorDrawingProtocol {
    @discardableResult
    func drawSpecialData(type: String, data: String) -> Bool {
        false
    }
}

/// Reusable drawing code that can target a native drawer or a recorder.
public typealias ConcordVectorDrawingClosure = (_ drawer: any ConcordVectorDrawingProtocol) -> Void
