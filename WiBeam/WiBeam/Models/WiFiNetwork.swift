import Foundation
import CoreData

extension WiFiNetworkEntity {
    var securityType: WiFiSecurity {
        WiFiSecurity(rawValue: security ?? "WPA") ?? .wpa
    }

    var keychainAccount: String {
        "com.wibeam.wifi.\(id?.uuidString ?? UUID().uuidString)"
    }

    var displayInitial: String {
        String((ssid ?? "?").prefix(1)).uppercased()
    }

    var hasExpiry: Bool {
        expiryDate != nil
    }

    var isExpired: Bool {
        guard let expiryDate else { return false }
        return expiryDate < Date()
    }
}
