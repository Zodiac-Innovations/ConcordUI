//
//  ConcordPlatformPrintServices.swift
//  ConcordUI
//
//  Portable printing conveniences for text and bitmap images.
//

import Foundation

/// Optional native printing support used by ConcordUI's portable printing conveniences.
///
/// Printing is intentionally limited to content ConcordUI can currently render portably:
/// plain text and encoded bitmap images. PDF, SVG, markup, and vector printing can be added
/// when their corresponding rendering models are available.
public protocol ConcordPlatformPrintSupport: AnyObject {
    var canPrintTextContent: Bool { get }
    var canPrintImageContent: Bool { get }

    @discardableResult
    func printTextContent(_ text: String, font: ConcordFont) -> Bool

    @discardableResult
    func printImageContent(_ image: ConcordBitmapImage, size: Bool) -> Bool
}

public extension ConcordPlatform {
    private var printSupport: (any ConcordPlatformPrintSupport)? {
        self as? any ConcordPlatformPrintSupport
    }

    /// True when the running platform can present native printing for text.
    var canPrintText: Bool { printSupport?.canPrintTextContent ?? false }

    /// True when the running platform can present native printing for bitmap images.
    var canPrintImage: Bool { printSupport?.canPrintImageContent ?? false }

    /// Prints plain text through the platform's native printing UI.
    ///
    /// `.system` is the default and maps to the platform's conventional system font.
    @discardableResult
    func printText(_ text: String, font: ConcordFont = .system) -> Bool {
        guard canPrintText, let support = printSupport else { return false }
        return support.printTextContent(text, font: font)
    }

    /// Retrieves an embedded UTF-8 text file and prints it using the requested font.
    @discardableResult
    func printFileText(_ filename: String, font: ConcordFont = .system) -> Bool {
        guard canPrintText, let text = retrieveTextFile(filename) else { return false }
        return printText(text, font: font)
    }

    /// Prints an encoded bitmap image through the platform's native printing UI.
    ///
    /// When `size` is true, the image is proportionally scaled down or up to fit a single
    /// printable page. When false, the native implementation uses the bitmap's intrinsic size.
    @discardableResult
    func printImage(_ image: ConcordBitmapImage, size: Bool = true) -> Bool {
        guard canPrintImage, let support = printSupport else { return false }
        return support.printImageContent(image, size: size)
    }

    /// Retrieves an embedded PNG/JPEG file and prints it as a bitmap image.
    @discardableResult
    func printFileImage(_ filename: String, size: Bool = true) -> Bool {
        guard canPrintImage, let image = retrieveBitmapFile(filename) else { return false }
        return printImage(image, size: size)
    }
}
