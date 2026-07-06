import Foundation
import SwiftUI

enum AppGroupConfig {
    static let identifier = "group.com.zzoutuo.WiBeam"

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }

    static let lastWiFiUUIDKey = "lastWiFiUUID"
    static let hasSeenOnboardingKey = "hasSeenOnboarding"
    static let biometricLockEnabledKey = "biometricLockEnabled"
    static let iCloudSyncEnabledKey = "iCloudSyncEnabled"
    static let customStyleKey = "customStyle"
    static let lastSharedTimestampKey = "lastSharedTimestamp"
}

enum AppSettings {
    @AppStorage("biometricLockEnabled") static var biometricLockEnabled: Bool = false
    @AppStorage("iCloudSyncEnabled") static var iCloudSyncEnabled: Bool = false
    @AppStorage("customStyleEnabled") static var customStyleEnabled: Bool = false
    @AppStorage("customForegroundColor") static var customForegroundColorHex: String = "#000000"
    @AppStorage("customBackgroundColor") static var customBackgroundColorHex: String = "#FFFFFF"
    @AppStorage("embedLogo") static var embedLogo: Bool = false
    @AppStorage("widgetEnabled") static var widgetEnabled: Bool = false
    @AppStorage("lastSelectedWiFiUUID") static var lastSelectedWiFiUUID: String = ""
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: Double
        switch hex.count {
        case 6:
            (r, g, b, a) = (Double((int >> 16) & 0xFF) / 255,
                            Double((int >> 8) & 0xFF) / 255,
                            Double(int & 0xFF) / 255, 1)
        case 8:
            (r, g, b, a) = (Double((int >> 24) & 0xFF) / 255,
                            Double((int >> 16) & 0xFF) / 255,
                            Double((int >> 8) & 0xFF) / 255,
                            Double(int & 0xFF) / 255)
        default:
            (r, g, b, a) = (0, 0.478, 1, 1)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

enum AppTheme {
    static let primary = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let success = Color(red: 0.298, green: 0.847, blue: 0.392)
    static let warning = Color(red: 1.0, green: 0.722, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.231, blue: 0.188)
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let standardSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
}
