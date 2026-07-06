import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
final class AddWiFiViewModel: ObservableObject {
    @Published var ssid: String = ""
    @Published var password: String = ""
    @Published var security: WiFiSecurity = .wpa
    @Published var isHidden: Bool = false
    @Published var note: String = ""
    @Published var brandColor: Color = AppTheme.primary
    @Published var logoData: Data?
    @Published var expiryDate: Date?
    @Published var error: String?
    @Published var purchaseManager: PurchaseManager

    var editingNetwork: WiFiNetworkEntity?
    var onSaved: (() -> Void)?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil,
         purchaseManager: PurchaseManager? = nil,
         editing: WiFiNetworkEntity? = nil) {
        self.context = context ?? CoreDataStack.shared.viewContext
        self.purchaseManager = purchaseManager ?? .shared
        self.editingNetwork = editing

        if let editing {
            ssid = editing.ssid ?? ""
            security = editing.securityType
            isHidden = editing.isHidden
            note = editing.note ?? ""
            expiryDate = editing.expiryDate

            if let colorString = editing.brandColor, !colorString.isEmpty {
                brandColor = Color(hex: colorString)
            }
        }
    }

    var isEditing: Bool {
        editingNetwork != nil
    }

    var isPasswordRequired: Bool {
        security.requiresPassword
    }

    var ssidValidationError: String? {
        if ssid.isEmpty {
            return "Network name cannot be empty"
        }
        if ssid.count > 32 {
            return "Network name cannot exceed 32 characters"
        }
        return nil
    }

    var passwordValidationError: String? {
        guard security.requiresPassword else { return nil }
        if password.isEmpty {
            return "Password cannot be empty"
        }
        if password.count < security.minLength {
            return "Password must be at least \(security.minLength) characters for \(security.displayName)"
        }
        if password.count > security.maxLength {
            return "Password cannot exceed \(security.maxLength) characters for \(security.displayName)"
        }
        return nil
    }

    var isFormValid: Bool {
        ssidValidationError == nil && passwordValidationError == nil
    }

    func loadExistingPassword() async {
        guard let editingNetwork, isPasswordRequired else { return }
        if let savedPassword = try? KeychainService.read(account: editingNetwork.keychainAccount) {
            await MainActor.run {
                self.password = savedPassword
            }
        }
    }

    func save() -> Bool {
        guard isFormValid else {
            error = ssidValidationError ?? passwordValidationError
            return false
        }

        if !isEditing {
            if !purchaseManager.isPro {
                let request = WiFiNetworkEntity.fetchRequest()
                let count = (try? context.count(for: request)) ?? 0
                if count >= 3 {
                    error = "Free tier allows up to 3 networks. Upgrade to Pro for unlimited."
                    return false
                }
            }
        }

        let network: WiFiNetworkEntity
        if let editingNetwork {
            network = editingNetwork
        } else {
            network = WiFiNetworkEntity(context: context)
            network.id = UUID()
            network.createdAt = Date()
            network.shareCount = 0
            network.sortOrder = Int32.random(in: 0...1000)
        }

        network.ssid = ssid.trimmingCharacters(in: .whitespacesAndNewlines)
        network.security = security.rawValue
        network.isHidden = isHidden
        network.note = note.isEmpty ? nil : note
        network.brandColor = brandColor.hexString
        network.logoData = logoData
        network.expiryDate = expiryDate
        network.updatedAt = Date()
        network.isFavorite = network.isFavorite

        if security.requiresPassword {
            do {
                try KeychainService.save(password: password, account: network.keychainAccount)
            } catch {
                self.error = error.localizedDescription
                return false
            }
        } else {
            try? KeychainService.delete(account: network.keychainAccount)
        }

        CoreDataStack.shared.save()
        onSaved?()
        return true
    }
}
