# Capabilities Configuration

## Analysis
Based on operation guide analysis of `TR-20260706-WiFi密码分享器-操作指南.MD` and `us.md`:

| Requirement | Keyword Found | Capability Needed |
|-------------|---------------|-------------------|
| "iCloud同步" / "CloudKit" / "跨设备同步" | ✅ in guide §3.1, §5.5, §7.3 | iCloud (CloudKit) |
| "Keychain" / "密码加密" / "生物识别" | ✅ in guide §5.2, §6.3, §6.4 | Keychain Sharing + Face ID |
| "WidgetKit小组件" / "主屏快速访问" | ✅ in guide §3.1, §6.7 | App Groups (for widget data sharing) |
| "购买" / "订阅" / "Pro" / "买断" | ✅ in guide §7 | In-App Purchase (StoreKit 2) |
| "保存到相册" / "QR码保存" | ✅ in guide §4.3, §8.6 | Photo Library Add |
| "分享" / "AirDrop" / "AirPrint" | ✅ in guide §4.4, §4.6 | Share Sheet (no capability needed) |

## Auto-Configured Capabilities

| Capability | Status | Method | Details |
|------------|--------|--------|---------|
| App Groups | ✅ Configured | Entitlements file | `group.com.zzoutuo.WiBeam` — enables data sharing between main app and Widget Extension |
| iCloud (CloudKit) | ✅ Entitlements added | Entitlements file | `iCloud.com.zzoutuo.WiBeam` container ID + CloudKit service declared |
| Keychain Sharing | ✅ Configured | Entitlements file | `$(AppIdentifierPrefix)com.zzoutuo.WiBeam` — enables iCloud Keychain sync for Pro feature |
| In-App Purchase | ✅ Available | Xcode auto-enables with paid developer account | StoreKit 2 — no entitlement needed; product IDs configured in App Store Connect (PHASE 3) |
| Face ID | ✅ Configured | Info.plist key | `NSFaceIDUsageDescription` = "WiBeam uses Face ID to protect your WiFi passwords." |
| Photo Library Add | ✅ Configured | Info.plist key | `NSPhotoLibraryAddUsageDescription` = "WiBeam saves QR codes to your Photos library for sharing." |
| AccentColor | ✅ Configured | Asset Catalog | WiBeam Blue: RGB(0, 0.478, 1.0) with dark mode variant |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| iCloud Container | ⏳ Pending | 1. Log in to Apple Developer Portal → Identifiers → iCloud Containers → Create `iCloud.com.zzoutuo.WiBeam`<br>2. In Xcode → Signing & Capabilities → iCloud → select the container<br>3. **App works without this**: local CoreData storage is default; iCloud sync is a Pro enhancement only |
| App Group Provisioning | ⏳ Pending | 1. App Group `group.com.zzoutuo.WiBeam` may need to be registered in Apple Developer Portal → Identifiers → App Groups<br>2. **App works without this**: Widget Extension will be added in code generation; main app works standalone |
| IAP Products | ⏳ Pending | 1. In App Store Connect → My Apps → WiBeam → In-App Purchases<br>2. Create 3 products: `com.wibeam.lifetime` ($9.99), `com.wibeam.pro.monthly` ($1.99), `com.wibeam.pro.annual` ($14.99)<br>3. **App works without this**: Free tier works; Pro features show paywall but purchases will fail in sandbox until configured |

## No Configuration Needed

- **Push Notifications**: Not required — app is fully offline-first, no server-side notifications
- **Location Services**: Not required — no GPS usage
- **HealthKit**: Not required — no health data
- **Camera**: Not required — QR scanning uses iOS native camera, not in-app scanning
- **Siri**: Not required — no Siri integration
- **Apple Watch**: Not required for MVP (Phase 2 feature, not in Phase 1 MVP scope)
- **Background Modes**: Not required — WidgetKit handles background updates natively

## Verification
- Build succeeded after configuration: ✅ (12.5s, 0 errors, 0 warnings)
- All entitlements correct: ✅ (WiBeam.entitlements linked in both Debug and Release)
- App icon configured: ✅ (3 appearances: light, dark, tinted)
- AccentColor configured: ✅ (WiBeam Blue with dark mode variant)
- Info.plist usage descriptions added: ✅ (Face ID + Photo Library)

## Graceful Degradation
The app is designed to work with ZERO manual configuration:
- **Without iCloud Container**: CoreData uses local storage (default behavior); iCloud sync is a Pro enhancement
- **Without App Group provisioning**: Main app works; Widget Extension data sharing won't work until provisioned
- **Without IAP products**: Free tier fully functional; Paywall displays but purchases fail gracefully with error message
- **Without Keychain Sharing**: Passwords stored locally in Keychain (device-only); iCloud Keychain sync won't work until provisioned
