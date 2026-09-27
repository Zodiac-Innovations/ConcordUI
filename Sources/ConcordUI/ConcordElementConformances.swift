//
//  ConcordElementConformances.swift
//  ConcordUI
//
//  Declares the orthogonal capabilities supported by each current element type.
//

private typealias ConcordCommonColors = ConcordForegroundColorable & ConcordBackgroundColorable & ConcordFrameColorable

extension ConcordContainer: ConcordConfigurable, ConcordEdgeInsettable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordLabel: ConcordConfigurable, ConcordTextPresentable, ConcordLabeled, ConcordFontable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordHelpable, ConcordErrorPresentable, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordSpacer: ConcordConfigurable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordDivider: ConcordConfigurable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordButton: ConcordConfigurable, ConcordActionable, ConcordReadOnly, ConcordFontable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordHelpable, ConcordErrorPresentable, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}

extension ConcordTextElement: ConcordConfigurable, ConcordTextPresentable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordPlaceholderPresentable, ConcordRegexValidatable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}

extension ConcordBoolElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordTwoState, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {
    public var firstName: String { get { trueName } set { trueName = newValue } }
    public var secondName: String { get { falseName } set { falseName = newValue } }
}

extension ConcordIntElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordPlaceholderPresentable, ConcordRangeSteppable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordFloatElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordPlaceholderPresentable, ConcordRangeSteppable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}

extension ConcordDateElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordDateRangeable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordTimeElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordDateRangeable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordDateTimeElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordDateRangeable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}

extension ConcordImage: ConcordConfigurable, ConcordImagePresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordHelpable, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordRasterElement: ConcordConfigurable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordHelpable, ConcordDebuggable, ConcordBackgroundColorable, ConcordFrameColorable {}
extension ConcordProgressElement: ConcordConfigurable, ConcordFontable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordHelpable, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable {}

extension ConcordStringSelectionElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordIndexSelectionElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordStringTaggedSelectionElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
extension ConcordIntTaggedSelectionElement: ConcordConfigurable, ConcordBindable, ConcordEditable, ConcordActionable, ConcordRequired, ConcordFontable, ConcordHelpable, ConcordErrorPresentable, ConcordBoxable, ConcordSizable, ConcordJustifiable, ConcordAccessible, ConcordDebuggable, ConcordForegroundColorable, ConcordBackgroundColorable, ConcordFrameColorable, ConcordTextColorable {}
