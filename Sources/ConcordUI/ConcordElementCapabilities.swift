//
//  ConcordElementCapabilities.swift
//  ConcordUI
//
//  Defines orthogonal capabilities that ConcordUI elements may adopt.
//

import Foundation

// MARK: - Common Element Configuration

/// Common identity and state configuration shared by ConcordUI elements.
public protocol ConcordConfigurable: AnyObject {
    var name: String { get set }
    var tag: Int { get set }
    var position: Int? { get set }
    var isVisible: Bool { get set }
    var isEnabled: Bool { get set }
}

public extension ConcordConfigurable {
    @discardableResult func named(_ name: String) -> Self { self.name = name; return self }
    @discardableResult func tagged(_ tag: Int) -> Self { self.tag = tag; return self }
    @discardableResult func positioned(_ position: Int?) -> Self { self.position = position; return self }
    @discardableResult func visible(_ visible: Bool = true) -> Self { isVisible = visible; return self }
    @discardableResult func enabled(_ enabled: Bool = true) -> Self { isEnabled = enabled; return self }
}

/// An element that can display a semantic prefix/label before its primary value.
public protocol ConcordLabeled: AnyObject { var label: String? { get set } }
public extension ConcordLabeled {
    @discardableResult func label(_ text: String?) -> Self { label = text; return self }
}

/// A container whose content inset can be configured.
public protocol ConcordEdgeInsettable: AnyObject { var edge: Double { get set } }
public extension ConcordEdgeInsettable {
    @discardableResult func edge(_ edge: Double) -> Self { self.edge = edge; return self }
}

// MARK: - Embedded Resource Content

/// An element whose primary displayed content is text.
public protocol ConcordTextPresentable: AnyObject {
    var text: String { get set }
}

public extension ConcordTextPresentable {
    /// Replaces the element's text with an embedded UTF-8 text resource.
    ///
    /// The logical resource name has no directory or filename extension.
    /// If retrieval fails, the element's existing text is preserved.
    @discardableResult
    func resourceText(_ name: String, using platform: any ConcordPlatform) -> Self {
        guard let retrievedText = platform.textRetrieve(name: name) else { return self }
        text = retrievedText
        return self
    }
}

/// An element whose primary displayed content is portable image data.
public protocol ConcordImagePresentable: AnyObject {
    var imageData: ConcordImageData { get set }
}

public extension ConcordImagePresentable {
    /// Replaces the element's image with a named embedded PNG or JPEG resource.
    ///
    /// Retrieval verifies that the embedded image can be read. The native renderer
    /// then loads that resource by logical name. If retrieval fails, the element's
    /// existing image is preserved.
    @discardableResult
    func resourceImage(_ name: String, using platform: any ConcordPlatform) -> Self {
        guard platform.imageRetrieve(name: name) != nil else { return self }
        imageData = .asset(name)
        return self
    }
}

// MARK: - Value / Editing Capabilities

public protocol ConcordValueElement: AnyObject {
    associatedtype Value
    var value: Value { get set }
}

public protocol ConcordBindable: ConcordValueElement {
    var isBound: Bool { get }
}

public protocol ConcordReadOnly: AnyObject {
    var isReadOnly: Bool { get set }
}

public extension ConcordReadOnly {
    @discardableResult func readOnly(_ readOnly: Bool = true) -> Self {
        isReadOnly = readOnly; return self
    }
}

public protocol ConcordEditable: ConcordReadOnly {
    var isEnabled: Bool { get set }
}

// MARK: - Action Capability

public protocol ConcordActionable: AnyObject {
    @discardableResult func onAction(_ type: ConcordActionType, _ action: @escaping ConcordActionClosure) -> Self
    @discardableResult func removeAction(_ type: ConcordActionType) -> Self
}

// MARK: - Form / Validation Presentation Capabilities

public protocol ConcordRequired: AnyObject { var isRequired: Bool { get set } }
public extension ConcordRequired {
    @discardableResult func required(_ required: Bool = true) -> Self { isRequired = required; return self }
}

public protocol ConcordHelpable: AnyObject { var helpText: String? { get set } }
public extension ConcordHelpable {
    @discardableResult func help(_ text: String?) -> Self { helpText = text; return self }
}

public protocol ConcordErrorPresentable: AnyObject { var errorText: String? { get set } }
public extension ConcordErrorPresentable {
    @discardableResult func error(_ text: String?) -> Self { errorText = text; return self }
}

// MARK: - Semantic Configuration Capabilities

/// An element that can display placeholder text while its value is absent.
public protocol ConcordPlaceholderPresentable: AnyObject { var placeholder: String? { get set } }
public extension ConcordPlaceholderPresentable {
    @discardableResult func placeholder(_ text: String?) -> Self { placeholder = text; return self }
}

/// An element that presents two semantically named states.
public protocol ConcordTwoState: AnyObject {
    var firstName: String { get set }
    var secondName: String { get set }
}

public extension ConcordTwoState {
    @discardableResult func names(first: String, second: String) -> Self {
        firstName = first; secondName = second; return self
    }

    @discardableResult func nameYesNo() -> Self {
        names(first: ConcordString.yes, second: ConcordString.no)
    }

    @discardableResult func nameTrueFalse() -> Self {
        names(first: ConcordString.trueText, second: ConcordString.falseText)
    }

    @discardableResult func nameOnOff() -> Self {
        names(first: ConcordString.on, second: ConcordString.off)
    }

    @discardableResult func setNames(_ first: String, _ second: String) -> Self { names(first: first, second: second) }
    @discardableResult func setNamesYesNo() -> Self { nameYesNo() }
    @discardableResult func setNamesTrueFalse() -> Self { nameTrueFalse() }
    @discardableResult func setNamesOnOff() -> Self { nameOnOff() }
}

/// Text whose validity can be described by a regular-expression rule.
public protocol ConcordRegexValidatable: AnyObject {
    var regex: String? { get set }
    var regexErrorMessage: String? { get set }
}

public extension ConcordRegexValidatable {
    @discardableResult func regex(_ pattern: String, error: String? = nil) -> Self {
        regex = pattern
        regexErrorMessage = error
        return self
    }
}

/// A numeric element whose useful range and increment can be configured together.
public protocol ConcordRangeSteppable: AnyObject {
    associatedtype NumericValue: Comparable
    var range: ClosedRange<NumericValue>? { get set }
    var step: NumericValue { get set }
    func concordNormalizedStep(_ value: NumericValue) -> NumericValue
}

public extension ConcordRangeSteppable {
    @discardableResult
    func range(_ range: ClosedRange<NumericValue>, step: NumericValue? = nil) -> Self {
        self.range = range
        if let step { self.step = concordNormalizedStep(step) }
        return self
    }

    @discardableResult
    func step(_ step: NumericValue) -> Self {
        self.step = concordNormalizedStep(step)
        return self
    }
}

// MARK: - Presentation Capabilities

/// General foreground color for an element's visible content.
public protocol ConcordForegroundColorable: AnyObject { var foregroundColor: ConcordColor? { get set } }
public extension ConcordForegroundColorable {
    @discardableResult func foregroundColor(_ color: ConcordColor?) -> Self { foregroundColor = color; return self }
}

/// Background color behind an element.
public protocol ConcordBackgroundColorable: AnyObject { var backgroundColor: ConcordColor? { get set } }
public extension ConcordBackgroundColorable {
    @discardableResult func backgroundColor(_ color: ConcordColor?) -> Self { backgroundColor = color; return self }
}

/// Color used for the element frame/box stroke.
public protocol ConcordFrameColorable: AnyObject { var frameColor: ConcordColor? { get set } }
public extension ConcordFrameColorable {
    @discardableResult func frameColor(_ color: ConcordColor?) -> Self { frameColor = color; return self }
}

/// Color specifically used for an editable/displayed textual value when it should differ from general foreground color.
public protocol ConcordTextColorable: AnyObject { var textColor: ConcordColor? { get set } }
public extension ConcordTextColorable {
    @discardableResult func textColor(_ color: ConcordColor?) -> Self { textColor = color; return self }
}

/// An element that displays text and can request a portable abstract font family and size.
/// Nil values mean use the resolved registry display defaults.
public protocol ConcordFontable: AnyObject {
    var font: ConcordFont? { get set }
    var fontSize: Double? { get set }
}
public extension ConcordFontable {
    @discardableResult func font(_ font: ConcordFont?) -> Self { self.font = font; return self }
    @discardableResult func fontSize(_ size: Double?) -> Self { fontSize = size; return self }
    @discardableResult func systemFont() -> Self { font(.system) }
    @discardableResult func monospacedFont() -> Self { font(.monospaced) }
}

public protocol ConcordBoxable: AnyObject { var boxStyle: ConcordBoxStyle? { get set } }
public extension ConcordBoxable {
    @discardableResult func boxed(width: Double = 1, cornerRadius: Double = 0, padding: Double = 4) -> Self {
        boxStyle = ConcordBoxStyle(width: width, cornerRadius: cornerRadius, padding: padding); return self
    }
    @discardableResult func unboxed() -> Self { boxStyle = nil; return self }
}

public protocol ConcordSizable: AnyObject { var structure: ConcordElementStructure? { get set } }
public extension ConcordSizable {
    @discardableResult func fixedWidth(_ width: Double) -> Self { ensureConcordStructure(); structure?.width = .fixed(width); return self }
    @discardableResult func fixedHeight(_ height: Double) -> Self { ensureConcordStructure(); structure?.height = .fixed(height); return self }
    @discardableResult func fixedSize(width: Double, height: Double) -> Self { ensureConcordStructure(); structure?.width = .fixed(width); structure?.height = .fixed(height); return self }
    @discardableResult func fillWidth() -> Self { ensureConcordStructure(); structure?.width = .fill; return self }
    @discardableResult func fillHeight() -> Self { ensureConcordStructure(); structure?.height = .fill; return self }
    @discardableResult func fillSize() -> Self { ensureConcordStructure(); structure?.width = .fill; structure?.height = .fill; return self }
    @discardableResult func contentWidth() -> Self { ensureConcordStructure(); structure?.width = .content; return self }
    @discardableResult func contentHeight() -> Self { ensureConcordStructure(); structure?.height = .content; return self }
    private func ensureConcordStructure() { if structure == nil { structure = ConcordElementStructure() } }
}

public protocol ConcordJustifiable: AnyObject { var horizontalJustification: ConcordHorizontalJustification? { get set } }
public extension ConcordJustifiable {
    @discardableResult func leftJustified() -> Self { horizontalJustification = .left; return self }
    @discardableResult func centerJustified() -> Self { horizontalJustification = .center; return self }
    @discardableResult func rightJustified() -> Self { horizontalJustification = .right; return self }
}

public protocol ConcordAccessible: AnyObject { var accessibilityText: String? { get set } }
public extension ConcordAccessible {
    @discardableResult func accessibility(_ text: String?) -> Self { accessibilityText = text; return self }
}

public protocol ConcordDebuggable: AnyObject { var debugString: String? { get set } }
public extension ConcordDebuggable {
    @discardableResult func debug(_ text: String?) -> Self { debugString = text; return self }
}
