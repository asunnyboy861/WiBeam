import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import SwiftUI

enum QRGeneratorService {
    static func generateQRImage(from qrData: WiFiQRData,
                                scale: Int = 10,
                                foregroundColor: Color = .black,
                                backgroundColor: Color = .white,
                                logo: UIImage? = nil) -> UIImage? {
        let qrString = qrData.qrString
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = qrString.data(using: .utf8) ?? Data()
        filter.correctionLevel = "H"

        guard let ciImage = filter.outputImage else { return nil }

        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))

        let coloredImage = applyColors(to: transformed, foreground: foregroundColor, background: backgroundColor)

        guard let cgImage = context.createCGImage(coloredImage, from: transformed.extent) else { return nil }
        var uiImage = UIImage(cgImage: cgImage)

        if let logo {
            uiImage = embedLogo(logo, into: uiImage)
        }

        return uiImage
    }

    private static func applyColors(to image: CIImage, foreground: Color, background: Color) -> CIImage {
        let fgUIColor = UIColor(foreground)
        let bgUIColor = UIColor(background)

        var fgR: CGFloat = 0, fgG: CGFloat = 0, fgB: CGFloat = 0, fgA: CGFloat = 0
        fgUIColor.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        var bgR: CGFloat = 0, bgG: CGFloat = 0, bgB: CGFloat = 0, bgA: CGFloat = 0
        bgUIColor.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)

        let colorMatrixFilter = CIFilter.colorMatrix()
        colorMatrixFilter.inputImage = image
        colorMatrixFilter.rVector = CIVector(x: CGFloat(fgR - bgR), y: 0, z: 0, w: 0)
        colorMatrixFilter.gVector = CIVector(x: 0, y: CGFloat(fgG - bgG), z: 0, w: 0)
        colorMatrixFilter.bVector = CIVector(x: 0, y: 0, z: CGFloat(fgB - bgB), w: 0)
        colorMatrixFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrixFilter.biasVector = CIVector(x: CGFloat(bgR), y: CGFloat(bgG), z: CGFloat(bgB), w: 0)

        return colorMatrixFilter.outputImage ?? image
    }

    private static func embedLogo(_ logo: UIImage, into qrImage: UIImage) -> UIImage {
        let size = qrImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            qrImage.draw(in: CGRect(origin: .zero, size: size))

            let logoSize = size.width * 0.2
            let padding: CGFloat = 8
            let logoFrame = CGRect(
                x: (size.width - logoSize) / 2,
                y: (size.height - logoSize) / 2,
                width: logoSize,
                height: logoSize
            )

            let whitePad = logoFrame.insetBy(dx: -padding, dy: -padding)
            UIColor.white.setFill()
            UIBezierPath(roundedRect: whitePad, cornerRadius: padding).fill()

            logo.draw(in: logoFrame)
        }
    }

    static func generatePDF(title: String, qrImage: UIImage, brandColor: Color = AppTheme.primary) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        return renderer.pdfData { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor(brandColor)
            ]
            let titleRect = CGRect(x: 0, y: 100, width: pageRect.width, height: 60)
            (title as NSString).draw(in: titleRect, withAttributes: titleAttributes)

            let qrSize: CGFloat = 400
            let qrRect = CGRect(
                x: (pageRect.width - qrSize) / 2,
                y: 200,
                width: qrSize,
                height: qrSize
            )
            qrImage.draw(in: qrRect)

            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            let footerRect = CGRect(x: 0, y: pageRect.height - 60, width: pageRect.width, height: 20)
            "Powered by WiBeam".draw(in: footerRect, withAttributes: footerAttributes)
        }
    }
}
