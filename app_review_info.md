# App Review Information — WiBeam

## 1. Screen Recording

A screen recording has been captured on a physical iPhone running the latest iOS, demonstrating:

- Launching the app (no login required — the app opens directly to the WiFi list)
- Adding a new WiFi network (entering SSID, security type, and password)
- Generating and displaying a WiFi QR code
- Sharing a QR code via the system share sheet (AirDrop, Messages, etc.)
- Saving a QR code to the Photos library
- Accessing the Paywall (Settings → Upgrade to Pro) showing all 3 plans with pricing
- Purchasing a subscription (Monthly with 7-day free trial)
- Toggling Pro features: Biometric Lock, Home Screen Widget
- Using Contact Support (Settings → Contact Support → fill form → send)
- Accessing Privacy Policy and Terms of Use from Settings

The recording begins with a clean app launch and shows the typical user flow through all core features.

## 2. Device Models and Operating Systems Tested

| Device | OS | Role |
|--------|-----|------|
| iPhone 16 | iOS 18.4 | Primary testing device |
| iPhone XS Max | iOS 18.4 | Compatibility testing |
| iPad Pro 13-inch (M5) | iPadOS 18.4 | iPad compatibility |
| iPad Air 11-inch (M3) | iPadOS 18.4 | iPad compatibility |

All devices are physical hardware running the latest available OS.

## 3. App Purpose and Target Audience

**Purpose**: WiBeam lets anyone share WiFi network access instantly via scannable QR codes — no password typing, no platform limits. It turns a WiFi credential (SSID + password) into a standard ISO/IEC 18004 QR code that any smartphone camera can scan to auto-connect.

**Problem it solves**:
- Telling guests your WiFi password is awkward and error-prone (long passwords, special characters)
- Business owners (cafes, hotels, Airbnb hosts) need a simple way to share WiFi without repeating the password
- Existing methods (writing on whiteboards, texting passwords) are insecure and inconvenient

**Target audience**:
- Home users sharing WiFi with guests, family, or friends
- Airbnb hosts and small business owners (cafes, restaurants, co-working spaces)
- IT administrators who need to onboard employees to corporate WiFi
- Event organizers providing temporary WiFi access

**Value provided**: Replace the 30-second "what's the WiFi password?" ritual with a 1-second QR scan. Supports all phone platforms (iPhone, Android, Windows) — the recipient doesn't need WiBeam installed.

## 4. Setup and Access Instructions

- **No login or account required**. The app opens directly to the WiFi list after launch.
- **No demo account needed**. All free-tier features are immediately accessible.
- **Core flow**: Tap + → Enter SSID & password → Save → QR code appears → Share or save to Photos.
- **Pro features**: Settings → Upgrade to Pro → choose Monthly ($1.99/mo, 7-day trial), Annual ($14.99/yr), or Lifetime ($9.99 one-time).
- **Sandbox testing**: Use a StoreKit Configuration File in Xcode for testing IAP, or test via TestFlight with a Sandbox Apple ID.

## 5. External Services, Tools, and Platforms

| Service | Purpose | Data Sent |
|---------|---------|-----------|
| Apple StoreKit / App Store | In-app purchases and subscriptions | Purchase transactions only (Apple handles all payment) |
| iCloud (CloudKit) | Sync WiFi networks across user's Apple devices (Pro feature) | Network SSID and security type only (passwords stay in per-device Keychain) |
| Cloudflare Workers | Contact Support form backend — receives user feedback submissions | Name, email, subject, message, app_name (user voluntarily enters in Contact Support form) |
| iOS Keychain | Local encrypted storage of WiFi passwords | Passwords never leave the device |

No third-party analytics, advertising, or tracking services are used.

## 6. Regional Differences

The app functions consistently across all regions. There are no regional differences in features or content. All features are available globally. The app does not use location services or region-specific APIs.

## 7. Regulated Industry / Protected Material

Not applicable. WiBeam does not operate in a regulated industry and does not include protected third-party material.

---

## Additional Review Notes

### Login / Account
WiBeam does **not** require any account, registration, or login. The app is fully functional immediately after download. There is no user-generated content, no social features, and no content reporting/blocking mechanisms because the app is a single-user utility.

### Subscription Information (Guideline 3.1.2)
The Paywall view clearly displays:
- **Title**: Each plan's display name (WiBeam Pro Monthly, WiBeam Pro Annual, WiBeam Lifetime)
- **Length**: Per month, per year, or one-time — shown next to each plan's price
- **Price**: Displayed via StoreKit's `displayPrice` (localized by Apple)
- **Free trial**: Monthly plan shows "7-day free trial, then $1.99/month"
- **Auto-renewal disclosure**: "Cancel anytime in Settings → Apple ID → Subscriptions."
- **Legal links**: Privacy Policy and Terms of Use links are displayed below the Restore Purchases button in the Paywall
- **Restore Purchases**: Available in the Paywall

### Purpose Strings (Guideline 5.1.1)
- **Face ID** (`NSFaceIDUsageDescription`): "WiBeam uses Face ID to securely lock the app and protect your WiFi passwords from unauthorized access. When Biometric Lock is enabled, Face ID is required each time the app is opened. No biometric data leaves the device."
- **Photo Library** (`NSPhotoLibraryAddUsageDescription`): "WiBeam saves WiFi QR code images to your Photos library so you can share them via AirDrop, Messages, or print them. The app only writes QR code images it generates and never reads or accesses your existing photos."

### Data Privacy
- WiFi passwords are stored in the iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` protection
- No analytics, tracking, or advertising SDKs
- No data is sold or shared with third parties
- Contact Support form data is sent only when the user explicitly fills out and submits the form
