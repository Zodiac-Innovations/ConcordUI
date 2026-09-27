//
//  ConcordConditionalElements.swift
//  ConcordUI
//
//  Conditional element-list conveniences for platform-specific layouts.
//

/// Returns `elements` when `flag` is true. When false, returns a blank
/// placeholder that the containing Presentation removes during construction.
public func isListOnFlag(
    _ flag: Bool,
    _ elements: [ConcordElement]
) -> [ConcordElement] {
    flag ? elements : [ConcordBlankElement()]
}

public extension ConcordPlatform {
    func isIOSList(_ elements: [ConcordElement]) -> [ConcordElement] {
        isListOnFlag(platformType == .iOS, elements)
    }

    func isAndroidList(_ elements: [ConcordElement]) -> [ConcordElement] {
        isListOnFlag(platformType == .android, elements)
    }

    func isMacList(_ elements: [ConcordElement]) -> [ConcordElement] {
        isListOnFlag(platformType == .macOS, elements)
    }

    func isWindowList(_ elements: [ConcordElement]) -> [ConcordElement] {
        isListOnFlag(platformType == .windows, elements)
    }
}

public extension ConcordApplication {
    func isIOSList(_ elements: [ConcordElement]) -> [ConcordElement] {
        platform.isIOSList(elements)
    }

    func isAndroidList(_ elements: [ConcordElement]) -> [ConcordElement] {
        platform.isAndroidList(elements)
    }

    func isMacList(_ elements: [ConcordElement]) -> [ConcordElement] {
        platform.isMacList(elements)
    }

    func isWindowList(_ elements: [ConcordElement]) -> [ConcordElement] {
        platform.isWindowList(elements)
    }
}
