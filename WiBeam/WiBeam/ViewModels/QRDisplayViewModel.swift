import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
final class QRDisplayViewModel: ObservableObject {
    @Published var qrImage: UIImage?
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var showSavedToast: Bool = false
    @Published var showSharedToast: Bool = false
    @Published var customForegroundColor: Color = .black
    @Published var customBackgroundColor: Color = .white
    @Published var embedLogo: Bool = false
    @Published var purchaseManager: PurchaseManager

    let network: WiFiNetworkEntity
    private var cancellables = Set<AnyCancellable>()

    init(network: WiFiNetworkEntity,
         purchaseManager: PurchaseManager? = nil) {
        self.network = network
        let manager = purchaseManager ?? .shared
        self.purchaseManager = manager

        manager.$isPro
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.regenerateQR()
            }
            .store(in: &cancellables)
    }

    func loadPasswordAndGenerate() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let savedPassword = try KeychainService.read(account: network.keychainAccount) {
                self.password = savedPassword
            }
        } catch {
            self.error = "Could not retrieve password"
        }

        await MainActor.run {
            self.generateQRImage()
            AppGroupConfig.userDefaults?.set(network.id?.uuidString ?? "", forKey: AppGroupConfig.lastWiFiUUIDKey)
            AppSettings.lastSelectedWiFiUUID = network.id?.uuidString ?? ""
        }
    }

    func regenerateQR() {
        generateQRImage()
    }

    private func generateQRImage() {
        let qrData = WiFiQRData(
            ssid: network.ssid ?? "",
            password: password,
            security: network.securityType,
            isHidden: network.isHidden
        )

        let foreground: Color = purchaseManager.isPro && AppSettings.customStyleEnabled ? customForegroundColor : .black
        let background: Color = purchaseManager.isPro && AppSettings.customStyleEnabled ? customBackgroundColor : .white

        qrImage = QRGeneratorService.generateQRImage(
            from: qrData,
            scale: 10,
            foregroundColor: foreground,
            backgroundColor: background
        )

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func shareQR(completion: @escaping (Bool) -> Void) {
        guard let qrImage else {
            completion(false)
            return
        }
        ShareService.shareImage(qrImage) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showSharedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.showSharedToast = false
                    }
                }
                completion(success)
            }
        }
    }

    func saveToPhotos(completion: @escaping (Bool) -> Void) {
        guard let qrImage else {
            completion(false)
            return
        }
        ShareService.saveToPhotos(qrImage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.showSavedToast = false
                    }
                    completion(true)
                case .failure(let error):
                    self?.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func generatePosterPDF(title: String) -> Data? {
        guard let qrImage else { return nil }
        return QRGeneratorService.generatePDF(
            title: title,
            qrImage: qrImage,
            brandColor: Color(hex: network.brandColor ?? "#0080FF")
        )
    }
}
