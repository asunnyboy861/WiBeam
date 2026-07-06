import Foundation
import UIKit
import SwiftUI

enum ShareService {
    static func shareImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first?.rootViewController else {
                completion(false)
                return
            }

            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )

            activityViewController.completionWithItemsHandler = { _, completed, _, _ in
                completion(completed)
            }

            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(
                    x: rootViewController.view.bounds.midX,
                    y: rootViewController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }

            rootViewController.present(activityViewController, animated: true)
        }
    }

    static func saveToPhotos(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }

    static func sharePDF(_ pdfData: Data, fileName: String = "WiBeam-WiFi-Poster.pdf", completion: @escaping (Bool) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: tempURL)

            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = scene.windows.first?.rootViewController else {
                    completion(false)
                    return
                }

                let activityViewController = UIActivityViewController(
                    activityItems: [tempURL],
                    applicationActivities: nil
                )

                activityViewController.completionWithItemsHandler = { _, completed, _, _ in
                    try? FileManager.default.removeItem(at: tempURL)
                    completion(completed)
                }

                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = rootViewController.view
                    popover.sourceRect = CGRect(
                        x: rootViewController.view.bounds.midX,
                        y: rootViewController.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popover.permittedArrowDirections = []
                }

                rootViewController.present(activityViewController, animated: true)
            }
        } catch {
            completion(false)
        }
    }

    static func printPDF(_ pdfData: Data) {
        let controller = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "WiBeam WiFi Poster"
        controller.printInfo = printInfo
        controller.printingItem = pdfData

        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first?.rootViewController else {
                return
            }
            controller.present(animated: true, completionHandler: nil)
            _ = rootViewController
        }
    }
}
