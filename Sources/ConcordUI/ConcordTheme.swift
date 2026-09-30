import Foundation

/// Application-wide color defaults. Any nil value leaves that role to the native platform.
/// Individual element color modifiers override the corresponding theme value.
public struct ConcordTheme: Sendable, Equatable {
    public var foregroundColor: ConcordColor?
    public var backgroundColor: ConcordColor?
    public var frameColor: ConcordColor?
    public var textColor: ConcordColor?

    public init(
        foregroundColor: ConcordColor? = nil,
        backgroundColor: ConcordColor? = nil,
        frameColor: ConcordColor? = nil,
        textColor: ConcordColor? = nil
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.frameColor = frameColor
        self.textColor = textColor
    }

    /// Native platform defaults with no ConcordUI color overrides.
    public static let system = ConcordTheme()
}
