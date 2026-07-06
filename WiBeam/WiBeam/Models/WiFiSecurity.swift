import Foundation

enum WiFiSecurity: String, CaseIterable, Identifiable, Codable {
    case wpa = "WPA"
    case wep = "WEP"
    case nopass = "nopass"
    case wpa2 = "WPA2"
    case wpa3 = "WPA3"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wpa: return "WPA/WPA2"
        case .wep: return "WEP"
        case .nopass: return "None (Open)"
        case .wpa2: return "WPA2"
        case .wpa3: return "WPA3"
        }
    }

    var qrType: String {
        rawValue
    }

    var requiresPassword: Bool {
        self != .nopass
    }

    var minLength: Int {
        switch self {
        case .wpa, .wpa2, .wpa3: return 8
        case .wep: return 5
        case .nopass: return 0
        }
    }

    var maxLength: Int {
        switch self {
        case .wpa, .wpa2, .wpa3: return 63
        case .wep: return 13
        case .nopass: return 0
        }
    }

    var systemImage: String {
        switch self {
        case .wpa, .wpa2, .wpa3: return "lock.fill"
        case .wep: return "lock.shield"
        case .nopass: return "lock.open"
        }
    }
}
