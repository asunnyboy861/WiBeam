import Foundation

struct WiFiQRData {
    let ssid: String
    let password: String
    let security: WiFiSecurity
    let isHidden: Bool

    func escapedString(_ value: String) -> String {
        var result = value
        let specialChars: [(String, String)] = [
            ("\\", "\\\\"),
            ("\"", "\\\""),
            (";", "\\;"),
            (",", "\\,"),
            (":", "\\:")
        ]
        for (char, escaped) in specialChars {
            result = result.replacingOccurrences(of: char, with: escaped)
        }
        return result
    }

    var qrString: String {
        let escapedSSID = escapedString(ssid)
        let escapedPassword = escapedString(password)
        let escapedHidden = isHidden ? "true" : "false"

        if security == .nopass {
            return "WIFI:S:\(escapedSSID);T:nopass;H:\(escapedHidden);;"
        }

        return "WIFI:S:\(escapedSSID);T:\(security.qrType);P:\(escapedPassword);H:\(escapedHidden);;"
    }
}
