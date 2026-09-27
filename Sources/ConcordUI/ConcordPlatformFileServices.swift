//
//  ConcordPlatformFileServices.swift
//  ConcordUI
//
//  Typed conveniences for embedded application files and native sharing.
//

import Foundation

/// Optional platform support used by ConcordUI's typed embedded-file and sharing conveniences.
/// Platforms that do not conform automatically report these capabilities as unavailable.
public protocol ConcordPlatformFileSupport: AnyObject {
    var canRetrieveResources: Bool { get }
    var canOpenResources: Bool { get }
    var canShareResources: Bool { get }

    @discardableResult
    func resourceShare(name: String, type: ConcordResourceType) -> Bool

    @discardableResult
    func shareTextContent(_ text: String) -> Bool

    @discardableResult
    func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool
}

public extension ConcordPlatform {
    // MARK: Capability conveniences

    private var fileSupport: (any ConcordPlatformFileSupport)? {
        self as? any ConcordPlatformFileSupport
    }

    var canRetrieveData: Bool { fileSupport?.canRetrieveResources ?? false }
    var canRetrieveText: Bool { fileSupport?.canRetrieveResources ?? false }
    var canRetrieveBitmap: Bool { fileSupport?.canRetrieveResources ?? false }
    var canRetrievePDF: Bool { fileSupport?.canRetrieveResources ?? false }

    var canOpenData: Bool { fileSupport?.canOpenResources ?? false }
    var canOpenText: Bool { fileSupport?.canOpenResources ?? false }
    var canOpenBitmap: Bool { fileSupport?.canOpenResources ?? false }
    var canOpenPDF: Bool { fileSupport?.canOpenResources ?? false }

    var canShareData: Bool { fileSupport?.canShareResources ?? false }
    var canShareText: Bool { fileSupport?.canShareResources ?? false }
    var canShareBitmap: Bool { fileSupport?.canShareResources ?? false }
    var canSharePDF: Bool { fileSupport?.canShareResources ?? false }

    // MARK: Raw data files and values

    func retrieveDataFile(_ filename: String) -> Data? {
        guard canRetrieveData, let resource = resourceDescription(for: filename) else { return nil }
        return resourceRetrieve(name: resource.name, type: resource.type)
    }

    @discardableResult
    func openDataFile(_ filename: String) -> Bool {
        guard canOpenData, let resource = resourceDescription(for: filename) else { return false }
        return resourceOpen(name: resource.name, type: resource.type)
    }

    @discardableResult
    func shareDataFile(_ filename: String) -> Bool {
        guard canShareData,
              let resource = resourceDescription(for: filename),
              let support = fileSupport else { return false }
        return support.resourceShare(name: resource.name, type: resource.type)
    }

    @discardableResult
    func shareData(
        _ data: Data,
        filename: String = "SharedData.bin",
        mimeType: String = "application/octet-stream"
    ) -> Bool {
        guard canShareData, let support = fileSupport else { return false }
        return support.shareDataContent(data, filename: filename, mimeType: mimeType)
    }

    // MARK: Text files and values

    func retrieveTextFile(_ filename: String) -> String? {
        guard canRetrieveText, let name = typedResourceName(filename, allowedExtensions: ["txt"]) else { return nil }
        guard let data = resourceRetrieve(name: name, type: .text) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func openTextFile(_ filename: String) -> Bool {
        guard canOpenText, let name = typedResourceName(filename, allowedExtensions: ["txt"]) else { return false }
        return resourceOpen(name: name, type: .text)
    }

    @discardableResult
    func shareTextFile(_ filename: String) -> Bool {
        guard canShareText,
              let name = typedResourceName(filename, allowedExtensions: ["txt"]),
              let support = fileSupport else { return false }
        return support.resourceShare(name: name, type: .text)
    }

    @discardableResult
    func shareText(_ text: String) -> Bool {
        guard canShareText, let support = fileSupport else { return false }
        return support.shareTextContent(text)
    }

    // MARK: Bitmap files and values

    func retrieveBitmapFile(_ filename: String) -> ConcordBitmapImage? {
        guard canRetrieveBitmap,
              let name = typedResourceName(filename, allowedExtensions: ["png", "jpeg", "jpg"]),
              let data = resourceRetrieve(name: name, type: .image) else { return nil }
        return ConcordBitmapImage(data: data)
    }

    @discardableResult
    func openBitmapFile(_ filename: String) -> Bool {
        guard canOpenBitmap, let name = typedResourceName(filename, allowedExtensions: ["png", "jpeg", "jpg"]) else { return false }
        return resourceOpen(name: name, type: .image)
    }

    @discardableResult
    func shareBitmapFile(_ filename: String) -> Bool {
        guard canShareBitmap,
              let name = typedResourceName(filename, allowedExtensions: ["png", "jpeg", "jpg"]),
              let support = fileSupport else { return false }
        return support.resourceShare(name: name, type: .image)
    }

    @discardableResult
    func shareBitmap(_ bitmap: ConcordBitmapImage) -> Bool {
        guard canShareBitmap else { return false }
        switch bitmap.format {
        case .png:
            return shareData(bitmap.data, filename: "SharedImage.png", mimeType: "image/png")
        case .jpeg:
            return shareData(bitmap.data, filename: "SharedImage.jpg", mimeType: "image/jpeg")
        }
    }

    // MARK: PDF files and values

    func retrievePDFFile(_ filename: String) -> ConcordPDF? {
        guard canRetrievePDF,
              let name = typedResourceName(filename, allowedExtensions: ["pdf"]),
              let data = resourceRetrieve(name: name, type: .pdf) else { return nil }
        return ConcordPDF(data: data)
    }

    @discardableResult
    func openPDFFile(_ filename: String) -> Bool {
        guard canOpenPDF, let name = typedResourceName(filename, allowedExtensions: ["pdf"]) else { return false }
        return resourceOpen(name: name, type: .pdf)
    }

    @discardableResult
    func sharePDFFile(_ filename: String) -> Bool {
        guard canSharePDF,
              let name = typedResourceName(filename, allowedExtensions: ["pdf"]),
              let support = fileSupport else { return false }
        return support.resourceShare(name: name, type: .pdf)
    }

    @discardableResult
    func sharePDF(_ pdf: ConcordPDF) -> Bool {
        guard canSharePDF else { return false }
        return shareData(pdf.data, filename: "SharedDocument.pdf", mimeType: "application/pdf")
    }

    // MARK: Filename normalization

    private func typedResourceName(_ filename: String, allowedExtensions: Set<String>) -> String? {
        let url = URL(fileURLWithPath: filename)
        guard url.lastPathComponent == filename else { return nil }
        let ext = url.pathExtension.lowercased()
        guard ext.isEmpty || allowedExtensions.contains(ext) else { return nil }
        let name = ext.isEmpty ? filename : url.deletingPathExtension().lastPathComponent
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func resourceDescription(for filename: String) -> (name: String, type: ConcordResourceType)? {
        let url = URL(fileURLWithPath: filename)
        guard url.lastPathComponent == filename else { return nil }
        let ext = url.pathExtension.lowercased()
        let name = ext.isEmpty ? filename : url.deletingPathExtension().lastPathComponent
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        switch ext {
        case "txt": return (name, .text)
        case "pdf": return (name, .pdf)
        case "png", "jpeg", "jpg": return (name, .image)
        case "": return nil
        default: return (name, .custom(ext))
        }
    }
}
