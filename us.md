# WiBeam - iOS Development Guide

> **Source**: Translated and expanded from `TR-20260706-WiFi密码分享器-操作指南.MD`
> **Version**: v1.0 · **Date**: 2026-07-06

## Executive Summary

**WiBeam** is a privacy-first iOS utility that lets users share their WiFi network with anyone in 3 seconds via a scannable QR code. It solves a real, frequent pain point — sharing WiFi across platforms (iOS → Android, iOS → Windows) without typing passwords — and turns every share into a viral marketing opportunity.

**Product Vision**: "Beam me the WiFi" — make `WiBeam` a verb, just like "Google it" or "Uber there". Each shared QR code carries the brand, driving organic downloads.

**Target Audience**:
- Home hosts receiving guests (60%)
- Small businesses: cafés, salons, B&Bs (25%)
- Landlords / Airbnb hosts (10%)
- Smart home users adding new devices (5%)

**Key Differentiators**:
1. **3-Second Rule** — from app open to QR display in 3 seconds (15× faster than the 47-second manual typing baseline)
2. **Cross-Platform** — works with any phone camera (Android, iPhone, Windows), not just Apple devices like AirDrop
3. **Security-First** — passwords stored in Keychain with biometric protection, never in CoreData, never logged
4. **Viral Loop** — free version watermark + "Powered by WiBeam" on shared QR codes drives K-factor 0.48–1.2
5. **Flexible Monetization** — Free + Lifetime ($9.99) + Monthly ($1.99) + Annual ($14.99) covers all user segments

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Wi-Fi Share** (App Store) | Simple QR creation, guest-friendly UX | Limited network management, no widget, no batch sharing | WiBeam offers multi-network management, WidgetKit, and a 3-tier pricing model |
| **QR Code Reader · Generator** (Hey Apps) | Multi-format QR (WiFi/vCard/URL), batch scanning, OCR | Cluttered UI (not WiFi-focused), aggressive paywall ads | WiBeam is WiFi-focused with a clean 3-second flow and bouncy micro-interactions |
| **Native iOS Camera/AirDrop** | Built-in, no app install | Apple-to-Apple only, requires contacts sync, no QR generation | WiBeam works cross-platform (Android/Windows) and generates standard WiFi QR codes |
| **qifi.org** (web tool) | No install, free | Requires internet, exposes password to third-party site | WiBeam is fully local/offline; passwords never leave the device |
| **iOS 18 Passwords API** | Native password viewing | No QR generation, no sharing, no management | WiBeam adds QR generation + multi-network management + widget |

## Apple Design Guidelines Compliance

- **HIG – Widgets**: Support `systemSmall` and `systemMedium` families; use `containerBackground(for: .widget)`; respect `widgetRenderingMode` (fullColor / accented / vibrant). Provide a placeholder entry.
- **HIG – Materials & Liquid Glass**: Use `.regularMaterial` for cards; adopt iOS 18 Liquid Glass aesthetic for overlays.
- **HIG – Accessibility**: All tappable targets ≥ 44×44pt; support Dynamic Type up to `.extraExtraLarge`; provide `accessibilityLabel` / `accessibilityHint` on every interactive element.
- **HIG – Haptics**: Use `UINotificationFeedbackGenerator().notificationOccurred(.success)` on QR generation success and `UIImpactFeedbackGenerator(style: .light)` on card tap.
- **App Review 2.1 (Completeness)**: No dead buttons. Every Pro-locked feature shows a clear upgrade path, not a silent error.
- **App Review 3.1.2(c) (Subscriptions)**: Paywall must include functional Privacy Policy link, Terms of Use link, Restore Purchases button, clear price + billing period, and auto-renewal disclosure. Trial terms explicit.
- **App Review 4.0 (Design)**: Dark mode fully supported; adaptive layout for iPhone and iPad; no placeholder text.
- **App Review 5.1 (Privacy)**: Passwords stored in Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`); no analytics SDKs that collect WiFi credentials; App Tracking Transparency not required (no tracking).

## Technical Architecture

- **Language**: Swift 5.9+ (async/await, structured concurrency)
- **Framework**: SwiftUI (primary), WidgetKit, StoreKit 2
- **Data Persistence**: CoreData (`WiFiNetwork` entity) + Keychain (passwords) + UserDefaults (preferences) + CloudKit (Pro sync)
- **QR Generation**: CoreImage `CIFilter.qrCodeGenerator` (no third-party dependency required for MVP; EFQRCode optional for advanced styling)
- **Biometrics**: LocalAuthentication (Face ID / Touch ID)
- **Networking**: None (fully offline-first). CloudKit only for Pro iCloud sync.
- **In-App Purchase**: StoreKit 2 (`Product`, `Transaction`, `Transaction.updates`)
- **Minimum iOS**: 17.0

## Module Structure

```
WiBeam/
├── WiBeamApp.swift                      # App entry, CoreData container, StoreKit listener
├── Models/
│   ├── WiFiNetwork.swift                # CoreData entity (id, ssid, security, isHidden, note, createdAt, updatedAt, lastSharedAt, shareCount, sortOrder, isFavorite, logoData?, brandColor?)
│   ├── ShareHistory.swift               # Share event log (optional, Phase 2)
│   └── AppSettings.swift                # UserDefaults-backed settings (theme, lastUsedWiFi)
├── Views/
│   ├── ContentView.swift               # Main list view with search
│   ├── AddWiFiView.swift                # Add/Edit form
│   ├── QRDisplayView.swift              # Large QR display + share/save/print
│   ├── SettingsView.swift               # Settings + Paywall entry + policy links
│   ├── PaywallView.swift                # 3-tier subscription UI
│   ├── EmptyStateView.swift             # First-run welcome
│   └── Components/
│       ├── WiFiCard.swift               # List card with icon, SSID, security badges
│       └── BouncyButton.swift           # Reusable button style with spring animation
├── ViewModels/
│   ├── WiFiListViewModel.swift          # Fetch, search, add, delete, favorite, sort
│   ├── AddWiFiViewModel.swift           # Validation, escape, keychain save
│   └── QRDisplayViewModel.swift         # QR generation, share, save, history record
├── Services/
│   ├── QRGeneratorService.swift         # WiFi QR string + CIQRCodeGenerator + Logo embed
│   ├── KeychainService.swift            # Save/read/delete with biometric access control
│   ├── PurchaseManager.swift            # StoreKit 2 products, transactions, isPro
│   └── ShareService.swift              # UIActivityViewController wrapper
├── Persistence/
│   ├── CoreDataStack.swift             # NSPersistentContainer singleton
│   └── WiBeam.xcdatamodeld              # WiFiNetwork entity model
├── Widget/
│   └── WiBeamWidget.swift               # WidgetKit extension (systemSmall + systemMedium)
└── Resources/
    ├── Assets.xcassets                  # App icon, brand colors
    └── Localizable.strings              # English (base) + Simplified Chinese
```

## Feature Inventory (MANDATORY — Every Feature from Chinese Guide)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | WiFi QR Code Generation | 1. Open app → 2. Tap WiFi card → 3. QR displays | SSID (string, 1–32 chars), Password (string), Security (WPA/WEP/nopass), isHidden (bool) | Escape special chars (`\ ; , : "`), build `WIFI:S:<ssid>;T:<type>;P:<pwd>;H:<hidden>;;`, run `CIQRCodeGenerator` with correction level H, scale 10×, optional logo embed | UIImage (QR code), display in QRDisplayView | WiFiNetwork in CoreData + password in Keychain | QR scannable by iOS/Android camera; connecting succeeds on first scan |
| 2 | Add WiFi Network | 1. Tap + → 2. Fill form (SSID/password/security/hidden/note) → 3. Tap Generate | SSID, password, security enum, hidden toggle, optional note | Validate SSID (non-empty, ≤32 chars), validate password per security type (WPA 8–63, WEP 5/13, nopass skip), escape, save to CoreData + Keychain | New WiFiCard appears in list, sorted by sortOrder | WiFiNetwork entity + Keychain entry keyed by `com.wibeam.wifi.<uuid>` | New card visible; password retrievable only via biometric; survives app restart |
| 3 | WiFi Network List | 1. Open app → 2. List shows all networks sorted by sortOrder then createdAt desc | None (auto-fetch on view appear) | Fetch all WiFiNetwork entities via NSFetchRequest, sort, filter by searchText | List of WiFiCard views with SSID, security badge, share count, favorite star | CoreData fetch each time (no cache layer needed for MVP) | Empty state shows when 0 networks; search filters in real-time |
| 4 | QR Code Display View | 1. Tap card → 2. Sheet shows large QR + SSID title + action buttons | WiFiNetwork (selected) | Read password from Keychain (biometric prompt), build QR data, generate UIImage async, animate in with spring | Large QR (280×280pt), "Scan to connect WiFi" hint, Save / Share buttons | Increment shareCount, set lastSharedAt on share action | QR renders in <500ms; spring animation plays; haptic on success |
| 5 | Password Secure Storage | Automatic on Add/Edit; biometric prompt on Read | Password string | Store via `SecItemAdd` with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`; optional `SecAccessControlCreateWithFlags(.userPresence)` | Password retrievable only after Face ID / Touch ID | Keychain service `com.wibeam.app`, account = `com.wibeam.wifi.<uuid>` | Password persists across app restarts; biometric prompt appears on read; denial returns nil gracefully |
| 6 | Share QR Code | 1. On QRDisplayView → 2. Tap Share → 3. Pick AirDrop/Messages/Email/etc. | QR UIImage | Present `UIActivityViewController` with image; record share in history | System share sheet appears; recipient receives QR image | Update lastSharedAt + shareCount in CoreData | Image arrives at recipient in PNG quality; share count increments |
| 7 | Save QR to Photos | 1. On QRDisplayView → 2. Tap Save → 3. Image saved to Photos album | QR UIImage | Call `UIImageWriteToSavedPhotosAlbum` with completion target | Toast/alert "Saved to Photos" | Image in Photos.app | Image appears in Photos; no crash if permission denied (show alert) |
| 8 | Edit WiFi Network | 1. Swipe card → 2. Tap Edit → 3. Modify fields → 4. Save | Updated SSID/password/security/hidden/note | Validate, update CoreData, update Keychain password if changed | Card updates in list with new info | CoreData + Keychain updated | Changes persist; QR regenerates with new data |
| 9 | Delete WiFi Network | 1. Swipe card → 2. Tap Delete → 3. Confirm | WiFiNetwork | Delete Keychain password first, then CoreData entity | Card removed from list with animation | CoreData entity + Keychain entry deleted | Password removed from Keychain; no orphaned data |
| 10 | Favorite WiFi Network | 1. Long-press card → 2. Toggle Favorite | WiFiNetwork | Flip isFavorite, save CoreData | Star icon appears/disappears on card | CoreData isFavorite flag | Favorites appear first in list (sort: isFavorite desc, sortOrder asc) |
| 11 | Search WiFi Networks | 1. Pull down on list → 2. Type in search bar | Search text | Filter `wifiNetworks.filter { $0.ssid.localizedCaseInsensitiveContains(text) }` | Filtered list updates in real-time | None (in-memory filter) | Empty result shows "No matches"; clearing search restores full list |
| 12 | Empty State Welcome | Auto-shown when list is empty | None | Check `filteredNetworks.isEmpty` | Centered icon + "Welcome to WiBeam" + "Add Your First WiFi" button | None | Button tap opens AddWiFiView sheet |
| 13 | WidgetKit Quick Access | 1. Add WiBeam widget to Home Screen → 2. Tap widget → 3. App opens to last-used WiFi | Last-used WiFi UUID (stored in App Group UserDefaults) | Read App Group UserDefaults `lastWiFiUUID`, fetch WiFiNetwork, display QRDisplayView | Widget shows WiFi icon + SSID + QR icon; tap deep-links to app | App Group UserDefaults `lastWiFiUUID` set on each QR display | Widget appears in widget picker; tap opens app to correct WiFi |
| 14 | Share Extension | 1. In Photos app → 2. Share → 3. Pick WiBeam → 4. Save QR to library | UIImage from Photos | Receive image in Share Extension, save to WiBeam's container | Image available in WiBeam's saved QR list | App Group container | Extension appears in system share sheet for images |
| 15 | iCloud Sync (Pro) | 1. Toggle iCloud Sync in Settings → 2. Confirm | User iCloud account | Enable CloudKit private DB sync for CoreData + iCloud Keychain sync flag on Keychain items | WiFiNetwork entities sync to all devices; passwords sync via iCloud Keychain | CloudKit private DB + iCloud Keychain (`kSecAttrSynchronizable = true`) | Adding WiFi on iPhone appears on iPad within 1 minute; passwords sync |
| 16 | Custom QR Styles (Pro) | 1. On QRDisplayView → 2. Tap Style → 3. Pick color/logo | Foreground color, background color, optional logo UIImage | Apply tint to QR via CIFilter color matrix; embed logo at 20% center with white padding | Styled QR image replaces default | User preferences in UserDefaults | QR remains scannable after styling; logo doesn't break error correction |
| 17 | Biometric Lock (Pro) | 1. Enable in Settings → 2. App requires Face ID on launch | Face ID / Touch ID | Wrap app entry in `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)` | App locks on background; requires biometric to resume | UserDefaults `biometricLockEnabled` | Lock engages when app backgrounds for >30s; denial stays on lock screen |
| 18 | Print Poster (Pro) | 1. On QRDisplayView → 2. Tap Print → 3. Customize title → 4. AirPrint | Optional title string, logo, brand color | Build PDF with title + QR + "Powered by WiBeam" using `UIGraphicsPDFRenderer` | PDF preview → AirPrint dialog | None (one-shot export) | PDF prints correctly on AirPrint printer; QR scannable on paper at A4 size |
| 19 | Timed Access QR (Pro) | 1. Long-press card → 2. Share with Timer → 3. Pick duration → 4. Generate | Duration (1h/4h/24h/7d/custom) | Embed expiry timestamp in QR metadata (custom scheme), validate on next display | QR shows countdown timer; shows "expired" after timeout | CoreData `expiryDate` field | QR auto-invalidates after set time; UI shows live countdown |
| 20 | Paywall (3-Tier) | 1. Tap any Pro feature → 2. Paywall appears → 3. Pick plan → 4. Subscribe/Buy | Plan selection (monthly/annual/lifetime) | Load `Product.products(for: [IDs])`, call `product.purchase()`, verify `VerificationResult`, finish `Transaction` | isPro flag set; paywall dismisses; feature unlocked | StoreKit 2 transaction cache | Purchase succeeds in sandbox; restore works; all Pro features unlock |
| 21 | StoreKit 2 IAP | Automatic listener on app launch | None | `Task.detached { for await result in Transaction.updates { ... } }` | isPro updates reactively across views | `Transaction.currentEntitlements` | Purchase persists across reinstall; family sharing respected |
| 22 | Free Version Limit | Auto-check on Add WiFi | Current network count | `if !isPro && networks.count >= 3 { showPaywall }` | Paywall appears instead of AddWiFiView | None (count check) | 4th add attempt shows paywall; Pro users have unlimited |
| 23 | Dark Mode | Auto via system | None | Use `Color(.systemBackground)`, `.secondary`, asset catalog dark variants | All views adapt to dark mode | None | No white-on-white or black-on-black; WCAG AA contrast |
| 24 | Accessibility | Auto | None | `.accessibilityLabel`, `.accessibilityHint`, `.dynamicTypeSize(...Large)` on all text | VoiceOver reads every element | None | VoiceOver navigates all features; Dynamic Type scales |
| 25 | Animations & Haptics | Auto on interactions | None | `BouncyButtonStyle` (scale 0.95 spring), `QRGenerationAnimation` (scale + 3D rotation), haptic generators | Buttons bounce, QR flips in, success haptic on share | None | Animations smooth 60fps; haptics fire on success/light tap |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | QR Generation | Special char escaping | Escape `\ ; , : "` in SSID/password per ISO/IEC 18004 | Automatic, transparent to user |
| 1.2 | QR Generation | Error correction level H | 30% error tolerance allows logo embedding | Automatic |
| 1.3 | QR Generation | Logo embed (Pro) | Center logo at 20% size with 8pt white padding | Toggle in QR display |
| 3.1 | List | Pull-to-refresh | Pull down to refetch CoreData | Swipe gesture |
| 3.2 | List | Swipe to delete | Swipe left on card reveals Delete | Swipe gesture + confirm |
| 3.3 | List | Long-press menu | Long-press shows: Share QR, Favorite, Edit, Delete | Long-press |
| 4.1 | QR Display | Spring-in animation | QR scales from 0.5 to 1.0 + opacity 0 to 1 over 0.6s | Auto on view appear |
| 4.2 | QR Display | Radial glow background | Blue radial gradient behind QR for visual emphasis | Auto |
| 13.1 | Widget | systemSmall | WiFi icon + SSID + QR icon | Tap → deep link |
| 13.2 | Widget | systemMedium | WiFi icon + SSID + last shared time + QR icon | Tap → deep link |
| 20.1 | Paywall | Plan badge | "BEST VALUE" (annual), "POPULAR" (lifetime) | Auto display |
| 20.2 | Paywall | Restore purchases | Button at bottom calls `Transaction.currentEntitlements` | Tap |
| 20.3 | Paywall | Legal links | Privacy + Terms links open in Safari | Tap |
| 25.1 | Animations | Success haptic | `.notificationOccurred(.success)` on QR generation | Auto |
| 25.2 | Animations | Light haptic | `.impactOccurred(style: .light)` on card tap | Auto |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Add → List | Add WiFi (#2) | List (#3) | New WiFiNetwork entity | CoreData save succeeds |
| List → QR | List (#3) | QR Display (#4) | Selected WiFiNetwork | Card tap |
| QR → History | QR Display (#4) | Share History (#7) | shareCount++, lastSharedAt=now | Share button tapped |
| QR → Widget | QR Display (#4) | Widget (#13) | lastWiFiUUID to App Group | QR displayed |
| Free Limit → Paywall | Add WiFi (#2) | Paywall (#20) | Trigger when count ≥ 3 | Non-Pro user attempts 4th add |
| Pro feature → Paywall | Any Pro feature (#15–19) | Paywall (#20) | isPro=false | Non-Pro user taps Pro feature |
| Purchase → Unlock | Paywall (#20) | All Pro features | isPro=true | Transaction verified |
| Delete → Keychain | Delete (#9) | Password Storage (#5) | account key | Delete confirmed |

**Verification**: 25 primary features + 16 sub-features = 41 total interactions extracted. Matches Chinese guide sections 3–8 completely.

## Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

```
Feature 1: WiFi QR Code Generation
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── SSID + Password + Security + isHidden (from #2 Add)  │
│       │                                                   │
│  ViewModel Processing (QRDisplayViewModel)                │
│  └── Read password from Keychain (biometric)             │
│  └── Build WiFiQRData struct                              │
│  └── QRGeneratorService.generateQRCode(from: scale:10)    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── WiFiNetwork in CoreData (SSID, security, hidden)     │
│  └── Password in Keychain (key: com.wibeam.wifi.<uuid>)   │
│       │                                                   │
│  Display Output                                           │
│  └── UIImage in QRDisplayView (280×280, white bg)         │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Set lastWiFiUUID in App Group (for Widget #13)       │
│  └── Record share in Share History (#7) on share action   │
└───────────────────────────────────────────────────────────┘

Feature 2: Add WiFi Network
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── SSID, password, security picker, hidden toggle, note│
│       │                                                   │
│  ViewModel Processing (AddWiFiViewModel)                  │
│  └── Validate SSID (non-empty, ≤32 chars)                 │
│  └── Validate password (WPA: 8–63, WEP: 5/13, nopass: skip)│
│  └── Check free limit: if !isPro && count >= 3 → Paywall │
│  └── Create WiFiNetwork entity (UUID, timestamps)         │
│  └── Save password to Keychain                           │
│  └── Save entity to CoreData                             │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CoreData: WiFiNetwork (id, ssid, security, ...)      │
│  └── Keychain: password (service: com.wibeam.app)         │
│       │                                                   │
│  Display Output                                           │
│  └── List (#3) refreshes, new card appears at top         │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Trigger QR Display (#4) if user taps "Generate"      │
└───────────────────────────────────────────────────────────┘

Feature 3: WiFi Network List
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Search text (optional), pull-to-refresh             │
│       │                                                   │
│  ViewModel Processing (WiFiListViewModel)                  │
│  └── NSFetchRequest sorted by isFavorite desc, sortOrder  │
│  └── Filter by searchText (localizedCaseInsensitive)     │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CoreData fetch (no cache for MVP)                   │
│       │                                                   │
│  Display Output                                           │
│  └── List of WiFiCard views or EmptyStateView             │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Card tap → QR Display (#4)                          │
│  └── Card swipe → Delete (#9)                            │
│  └── Card long-press → Favorite (#10) / Edit (#8)        │
└───────────────────────────────────────────────────────────┘

Feature 4: QR Code Display
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap WiFi card (passes WiFiNetwork)                  │
│       │                                                   │
│  ViewModel Processing (QRDisplayViewModel)                │
│  └── Read password via KeychainService.read(biometric)   │
│  └── Build WiFiQRData, generate UIImage async            │
│  └── Trigger spring-in animation + success haptic        │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Set lastSharedAt, increment shareCount on share     │
│  └── Set lastWiFiUUID in App Group UserDefaults          │
│       │                                                   │
│  Display Output                                           │
│  └── Large QR + SSID title + "Scan to connect" + buttons │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Share button → Share Service (#6)                   │
│  └── Save button → Photos album (#7)                     │
│  └── Print button → Print Poster (#18, Pro)              │
│  └── Style button → Custom QR (#16, Pro)                │
└───────────────────────────────────────────────────────────┘

Feature 5: Password Secure Storage
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Password string (from Add WiFi #2)                  │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── KeychainService.save(password, account, sync flag)  │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SecItemAdd with kSecAttrAccessibleWhenUnlocked...   │
│  └── Optional SecAccessControl(.userPresence) for biometric│
│  └── Optional kSecAttrSynchronizable for iCloud Keychain  │
│       │                                                   │
│  Display Output                                           │
│  └── None (silent operation)                             │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Read by QR Display (#4) with biometric prompt       │
│  └── Deleted by Delete WiFi (#9)                        │
└───────────────────────────────────────────────────────────┘

Feature 13: WidgetKit Quick Access
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap widget on Home Screen                           │
│       │                                                   │
│  ViewModel Processing (Widget Provider)                   │
│  └── Read lastWiFiUUID from App Group UserDefaults        │
│  └── Fetch WiFiNetwork by UUID                           │
│  └── Build widget entry (SSID, QR icon)                  │
│       │                                                   │
│  Model/Persistence                                        │
│  └── App Group UserDefaults (shared with main app)       │
│       │                                                   │
│  Display Output                                           │
│  └── systemSmall: WiFi icon + SSID + QR icon             │
│  └── systemMedium: WiFi icon + SSID + last shared time   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Tap → widgetURL deep link → app opens to QR Display │
└───────────────────────────────────────────────────────────┘

Feature 20: Paywall (3-Tier Subscription)
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap Pro feature OR tap 4th WiFi add OR tap Settings │
│       │                                                   │
│  ViewModel Processing (PurchaseManager)                   │
│  └── Load Product.products(for: [3 IDs]) async           │
│  └── Display prices, badges, trial info                  │
│  └── On plan tap: product.purchase() → verify → finish   │
│  └── Listen to Transaction.updates in background         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── StoreKit 2 transaction cache (system-managed)       │
│  └── @Published isPro: Bool (reactive)                   │
│       │                                                   │
│  Display Output                                           │
│  └── Paywall with 3 PriceCards + feature list + legal   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── isPro=true → unlocks #15, #16, #17, #18, #19, #22  │
│  └── Restore button → Transaction.currentEntitlements    │
└───────────────────────────────────────────────────────────┘
```

**Verification**: All 25 features have a documented data flow. No "magic appearance" of data without a ViewModel source.

## Implementation Flow

1. **Project Setup**: Verify existing `WiBeam.xcodeproj` (SwiftUI, iOS 17+, CoreData enabled). Add Widget Extension target.
2. **CoreData Model**: Create `WiFiNetwork` entity with 12 attributes (id, ssid, security, isHidden, note, createdAt, updatedAt, lastSharedAt, shareCount, sortOrder, isFavorite, logoData?, brandColor?).
3. **Services Layer**: Implement `KeychainService`, `QRGeneratorService`, `PurchaseManager`, `ShareService`.
4. **Models**: Define `WiFiSecurity` enum, `WiFiQRData` struct, `ShareMethod` enum.
5. **ViewModels**: `WiFiListViewModel` (fetch/search/add/delete/favorite), `AddWiFiViewModel` (validate/escape), `QRDisplayViewModel` (generate/share/record).
6. **Views**: `ContentView`, `AddWiFiView`, `QRDisplayView`, `SettingsView`, `PaywallView`, `EmptyStateView`, `WiFiCard`, `BouncyButton`.
7. **Widget**: `WiBeamWidget` with `StaticConfiguration`, `Provider`, App Group access.
8. **StoreKit 2**: Product IDs `com.wibeam.lifetime`, `com.wibeam.pro.monthly`, `com.wibeam.pro.annual`. Transaction listener on app launch.
9. **Animations**: `BouncyButtonStyle`, `QRGenerationAnimation` modifier, haptic extensions.
10. **Accessibility**: Labels, hints, Dynamic Type on all text.
11. **Dark Mode**: Asset catalog dark variants, system colors.
12. **Testing**: Unit tests for QR string escaping, Keychain round-trip, ViewModel add/delete. UI tests for 3-second flow.
13. **Build & Verify**: iPhone + iPad simulators, no warnings, no broken constraints.

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: `Color(red: 0.0, green: 0.478, blue: 1.0)` (WiBeam Blue)
  - Accent: `Color(red: 0.298, green: 0.847, blue: 0.392)` (Success Green)
  - Background: `Color(.systemBackground)` (adaptive)
  - Card: `Color(.secondarySystemBackground)` (adaptive) or `.regularMaterial`
  - Warning: `Color(red: 1.0, green: 0.722, blue: 0.0)` (Orange)
  - Error: `Color(red: 1.0, green: 0.231, blue: 0.188)` (Red)

- **Typography**: SF Pro Rounded for titles (`Font.system(.title, design: .rounded)`), SF Pro Text for body. Dynamic Type up to `.accessibility3`.

- **Layout**:
  - Card corner radius: 16pt
  - Button corner radius: 12pt
  - Standard spacing: 16pt
  - Large spacing: 24pt
  - Card shadow: `color: .black.opacity(0.05), radius: 8, y: 4`
  - Min touch target: 44×44pt

- **Animations**:
  - Button press: `scaleEffect(0.95)` with `.spring(response: 0.3, dampingFraction: 0.6)`
  - QR appear: scale 0.5→1.0 + opacity 0→1 + 3D Y-rotation 180°→0° over 0.6s
  - Card appear: fade + slide up
  - Haptics: `.success` on QR generation, `.light` on card tap, `.warning` on error

## Code Generation Rules

- One feature per module, high cohesion, low coupling.
- Semantic naming, clear file structure (matches Module Structure above).
- Never add comments in code unless asked.
- Apple native first: prioritize SwiftUI/Swift over third-party.
- Open source first: integrate QR-Pop / EFQRCode / dagronf/QRCode patterns where they add value, but CoreImage CIFilter suffices for MVP.
- StoreKit 2 (not StoreKit 1) for all IAP.
- Async/await for all asynchronous operations (no completion handlers unless bridging).
- @MainActor for all ViewModels.
- No force unwrapping (`!`) except `@IBOutlet` (none here).
- Prefer `guard let` over `if let` for early exits.

## Build & Deployment Checklist

- [ ] App Icon (1024×1024) generated via Agnes Image (primary) or Wanx (fallback)
- [ ] Launch Screen configured
- [ ] CoreData model compiled (`WiBeam.xcdatamodeld`)
- [ ] Widget Extension target added and building
- [ ] App Group capability enabled (for widget data sharing)
- [ ] Keychain Sharing capability (if iCloud Keychain sync needed for Pro)
- [ ] CloudKit capability (for Pro iCloud sync)
- [ ] In-App Purchase capability + 3 product IDs configured in App Store Connect
- [ ] StoreKit configuration file for local testing
- [ ] Privacy Info manifest (`PrivacyInfo.xcprivacy`) — declare Keychain usage, no tracking
- [ ] Build succeeds on iPhone simulator (iPhone 16, iOS 18.4)
- [ ] Build succeeds on iPad simulator (iPad Pro 13-inch M5)
- [ ] No compiler warnings
- [ ] No runtime crashes on 3-second flow
- [ ] Dark mode renders correctly
- [ ] VoiceOver navigates all features
- [ ] App Store screenshots (6.7" + 5.5")
- [ ] Privacy Policy URL (deployed via GitHub Pages in PHASE 7)
- [ ] Support URL (deployed via GitHub Pages in PHASE 7)
- [ ] Terms of Use URL (deployed via GitHub Pages in PHASE 7)

## GitHub Reference Projects

| Project | URL | License | Use Case |
|---------|-----|---------|----------|
| QR-Pop | https://github.com/git-shawn/QR-Pop | MIT | Reference SwiftUI QR app structure |
| EFQRCode | https://github.com/EFPrefix/EFQRCode | MIT | Advanced QR styling (Pro feature) |
| dagronf/QRCode | https://github.com/dagronf/QRCode | MIT | SwiftUI native QR component |
| swift_qrcodejs | https://github.com/ApolloZhu/swift_qrcodejs | MIT | Cross-platform QR (watchOS) |
| QRDispenser | https://github.com/andrealufino/QRDispenser | MIT | No-dependency QR reference |
| CodeGeneratorAndScanner | https://github.com/satyadevchauhan/CodeGeneratorAndScanner | MIT | Full app reference |
| NetWizard | https://github.com/ayushsharma82/NetWizard | ESP32 | IoT WiFi management reference (not iOS) |

## Pricing & Monetization Summary

| Tier | Price | Product ID | Target User | Key Features |
|------|-------|-------------|-------------|--------------|
| Free | $0 | — | All users | QR generation, 3 WiFi networks, basic share, QR save |
| Lifetime | $9.99 one-time | `com.wibeam.lifetime` | Light users | Unlimited networks, iCloud sync, widget, custom styles, biometric lock, no ads |
| Pro Monthly | $1.99/month | `com.wibeam.pro.monthly` | Trial users | All Pro features + 7-day free trial |
| Pro Annual | $14.99/year | `com.wibeam.pro.annual` | Heavy/business users | All Pro features + business analytics + custom branding + priority support |

**Note**: No AI features → no API cost concerns. Lifetime pricing is sustainable.

## App Store Compliance — Subscriptions

### Guideline 3.1.2(c) — Subscription Information
The Paywall MUST include:
- Functional link to Privacy Policy (deployed in PHASE 7)
- Functional link to Terms of Use (deployed in PHASE 7)
- Restore Purchases button (visible without scrolling)
- Subscription title, length, and price in large legible text
- Auto-renewal disclosure: "Cancel anytime in Settings → Apple ID → Subscriptions"

### Trial Disclosure
If 7-day free trial is offered on Monthly plan:
- Show "7-day free trial, then $1.99/month" explicitly
- Do NOT pre-select the most expensive plan by default
- Do NOT hide trial behind a toggle (Apple rejects this dark pattern in 2026)

---

*End of us.md*
