import ConcordUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
private final class ConcordImagePrintRenderer: UIPrintPageRenderer {
    let image: UIImage
    let sizeToFit: Bool

    init(image: UIImage, sizeToFit: Bool) {
        self.image = image
        self.sizeToFit = sizeToFit
        super.init()
    }

    override var numberOfPages: Int { 1 }

    override func drawContentForPage(at pageIndex: Int, in contentRect: CGRect) {
        let natural = image.size
        let target: CGRect
        if sizeToFit {
            guard natural.width > 0, natural.height > 0 else { return }
            let scale = min(contentRect.width / natural.width, contentRect.height / natural.height)
            let width = natural.width * scale
            let height = natural.height * scale
            target = CGRect(
                x: contentRect.midX - width / 2,
                y: contentRect.midY - height / 2,
                width: width,
                height: height
            )
        } else {
            target = CGRect(
                x: contentRect.minX,
                y: contentRect.minY,
                width: natural.width,
                height: natural.height
            )
        }
        image.draw(in: target)
    }
}
#endif

public extension ConcordApplePlatform {
    var canPrintTextContent: Bool {
        #if canImport(UIKit)
        return UIPrintInteractionController.isPrintingAvailable
        #elseif canImport(AppKit)
        return true
        #else
        return false
        #endif
    }

    var canPrintImageContent: Bool { canPrintTextContent }

    @discardableResult
    func printTextContent(_ text: String, font: ConcordFont) -> Bool {
        #if canImport(UIKit)
        guard canPrintTextContent else { return false }
        let formatter = UISimpleTextPrintFormatter(text: text)
        switch font {
        case .system:
            formatter.font = UIFont.systemFont(ofSize: 12)
        case .monospaced:
            formatter.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        }
        let controller = UIPrintInteractionController.shared
        controller.printFormatter = formatter
        controller.present(animated: true, completionHandler: nil)
        return true
        #elseif canImport(AppKit)
        let nativeFont: NSFont
        switch font {
        case .system:
            nativeFont = NSFont.systemFont(ofSize: 12)
        case .monospaced:
            nativeFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        }
        let attributed = NSAttributedString(string: text, attributes: [.font: nativeFont])
        let bounds = attributed.boundingRect(
            with: NSSize(width: 612, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let textView = NSTextView(frame: NSRect(
            x: 0,
            y: 0,
            width: 612,
            height: max(792, ceil(bounds.height) + 24)
        ))
        textView.isEditable = false
        textView.isRichText = false
        textView.textStorage?.setAttributedString(attributed)
        let operation = NSPrintOperation(view: textView)
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true
        return operation.run()
        #else
        return false
        #endif
    }

    @discardableResult
    func printImageContent(_ image: ConcordBitmapImage, size: Bool) -> Bool {
        #if canImport(UIKit)
        guard canPrintImageContent, let nativeImage = UIImage(data: image.data) else { return false }
        let controller = UIPrintInteractionController.shared
        controller.printPageRenderer = ConcordImagePrintRenderer(image: nativeImage, sizeToFit: size)
        controller.present(animated: true, completionHandler: nil)
        return true
        #elseif canImport(AppKit)
        guard let nativeImage = NSImage(data: image.data) else { return false }
        let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 612, height: 792))
        imageView.image = nativeImage
        imageView.imageScaling = size ? .scaleProportionallyUpOrDown : .scaleNone
        imageView.imageAlignment = .alignCenter
        let operation = NSPrintOperation(view: imageView)
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true
        return operation.run()
        #else
        return false
        #endif
    }
}

extension ConcordApplePlatform: ConcordPlatformPrintSupport {}
