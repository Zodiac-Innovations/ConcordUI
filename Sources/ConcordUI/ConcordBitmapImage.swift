//
//  ConcordBitmapImage.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/29/26.
//
//  Defines portable encoded bitmap image data.
//

import Foundation

/// The encoded file format of a portable bitmap image.
public enum ConcordBitmapFormat: String, Codable, Sendable, Equatable {
    case png
    case jpeg
}

/// Platform-independent encoded bitmap image data.
///
/// Pixel dimensions describe the bitmap's intrinsic resolution. An element's displayed size
/// remains independent of these dimensions.
public struct ConcordBitmapImage: Codable, Sendable {
    public let data: Data
    public let format: ConcordBitmapFormat
    public let pixelWidth: ConcordInt
    public let pixelHeight: ConcordInt

    public init(
        data: Data,
        format: ConcordBitmapFormat,
        pixelWidth: ConcordInt,
        pixelHeight: ConcordInt
    ) {
        precondition(pixelWidth > 0, "Bitmap pixel width must be greater than zero")
        precondition(pixelHeight > 0, "Bitmap pixel height must be greater than zero")

        self.data = data
        self.format = format
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    /// Creates a bitmap image by reading the format and intrinsic dimensions from encoded PNG or JPEG data.
    public init?(data: Data) {
        if let dimensions = Self.pngDimensions(data) {
            self.init(data: data, format: .png, pixelWidth: dimensions.width, pixelHeight: dimensions.height)
            return
        }
        if let dimensions = Self.jpegDimensions(data) {
            self.init(data: data, format: .jpeg, pixelWidth: dimensions.width, pixelHeight: dimensions.height)
            return
        }
        return nil
    }

    public var aspectRatio: ConcordFloat {
        ConcordFloat(pixelWidth) / ConcordFloat(pixelHeight)
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case format
        case pixelWidth
        case pixelHeight
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .data)
        let format = try container.decode(ConcordBitmapFormat.self, forKey: .format)
        let pixelWidth = try container.decode(ConcordInt.self, forKey: .pixelWidth)
        let pixelHeight = try container.decode(ConcordInt.self, forKey: .pixelHeight)

        guard pixelWidth > 0, pixelHeight > 0 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Bitmap pixel dimensions must be greater than zero"
                )
            )
        }

        self.data = data
        self.format = format
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    private static func pngDimensions(_ data: Data) -> (width: ConcordInt, height: ConcordInt)? {
        let bytes = [UInt8](data)
        let signature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        guard bytes.count >= 24, Array(bytes.prefix(8)) == signature else { return nil }
        let width = readUInt32BE(bytes, at: 16)
        let height = readUInt32BE(bytes, at: 20)
        guard width > 0, height > 0 else { return nil }
        return (ConcordInt(width), ConcordInt(height))
    }

    private static func jpegDimensions(_ data: Data) -> (width: ConcordInt, height: ConcordInt)? {
        let bytes = [UInt8](data)
        guard bytes.count >= 4, bytes[0] == 0xFF, bytes[1] == 0xD8 else { return nil }

        var index = 2
        while index + 3 < bytes.count {
            while index < bytes.count, bytes[index] != 0xFF { index += 1 }
            while index < bytes.count, bytes[index] == 0xFF { index += 1 }
            guard index < bytes.count else { return nil }

            let marker = bytes[index]
            index += 1
            if marker == 0xD8 || marker == 0xD9 || (0xD0...0xD7).contains(marker) { continue }
            guard index + 1 < bytes.count else { return nil }
            let length = Int(bytes[index]) << 8 | Int(bytes[index + 1])
            guard length >= 2, index + length <= bytes.count else { return nil }

            let isStartOfFrame = (0xC0...0xC3).contains(marker)
                || (0xC5...0xC7).contains(marker)
                || (0xC9...0xCB).contains(marker)
                || (0xCD...0xCF).contains(marker)
            if isStartOfFrame {
                guard length >= 7 else { return nil }
                let height = Int(bytes[index + 3]) << 8 | Int(bytes[index + 4])
                let width = Int(bytes[index + 5]) << 8 | Int(bytes[index + 6])
                guard width > 0, height > 0 else { return nil }
                return (ConcordInt(width), ConcordInt(height))
            }
            index += length
        }
        return nil
    }

    private static func readUInt32BE(_ bytes: [UInt8], at index: Int) -> UInt32 {
        (UInt32(bytes[index]) << 24)
            | (UInt32(bytes[index + 1]) << 16)
            | (UInt32(bytes[index + 2]) << 8)
            | UInt32(bytes[index + 3])
    }
}
