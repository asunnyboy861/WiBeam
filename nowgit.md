# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | WiBeam |
| **Git URL** | git@github.com:asunnyboy861/WiBeam.git |
| **Repo URL** | https://github.com/asunnyboy861/WiBeam |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **Latest Commit** | ccf5634f — Initial commit: WiBeam iOS app |
| **Total Files Committed** | 45 |
| **GitHub Pages** | ⏳ Pending (will be enabled in PHASE 7) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/WiBeam/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/WiBeam/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/WiBeam/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/WiBeam/terms.html | ⏳ Pending (required for subscription) |

## Repository Structure

```
WiBeam/                              # GitHub repository root
├── WiBeam/                          # Xcode project root
│   ├── WiBeam.xcodeproj/            # Xcode project file
│   │   └── project.pbxproj          # Project configuration (incl. WiBeamWidget target)
│   ├── WiBeam/                      # Main app source
│   │   ├── Models/                  # Data models
│   │   │   ├── AppSettings.swift
│   │   │   ├── WiFiNetwork.swift
│   │   │   ├── WiFiQRData.swift
│   │   │   └── WiFiSecurity.swift
│   │   ├── Persistence/            # CoreData stack & model
│   │   │   ├── CoreDataStack.swift
│   │   │   └── WiBeam.xcdatamodeld/
│   │   ├── Services/                # Business logic services
│   │   │   ├── KeychainService.swift
│   │   │   ├── PurchaseManager.swift
│   │   │   ├── QRGeneratorService.swift
│   │   │   └── ShareService.swift
│   │   ├── ViewModels/              # MVVM ViewModels
│   │   │   ├── AddWiFiViewModel.swift
│   │   │   ├── QRDisplayViewModel.swift
│   │   │   └── WiFiListViewModel.swift
│   │   ├── Views/                   # SwiftUI Views
│   │   │   ├── Components/
│   │   │   │   ├── BouncyButton.swift
│   │   │   │   └── WiFiCard.swift
│   │   │   ├── AddWiFiView.swift
│   │   │   ├── ContactSupportView.swift
│   │   │   ├── ContentView.swift
│   │   │   ├── EmptyStateView.swift
│   │   │   ├── PaywallView.swift
│   │   │   ├── QRDisplayView.swift
│   │   │   └── SettingsView.swift
│   │   ├── Assets.xcassets/         # App icon & accent color
│   │   ├── WiBeam.entitlements      # App Groups, Keychain Sharing
│   │   └── WiBeamApp.swift          # App entry point
│   ├── WiBeamWidget/                # Widget extension
│   │   ├── WiBeamWidget.swift
│   │   └── WiBeamWidget.entitlements
│   ├── WiBeamWidget_Info.plist      # Widget Info.plist (external)
│   ├── WiBeamTests/                 # Unit tests
│   └── WiBeamUITests/               # UI tests
├── docs/                            # ⏳ Policy pages (will be added in PHASE 7)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/               # ⏳ GitHub Actions (will be added in PHASE 7)
│   └── deploy.yml
├── us.md                            # English development guide
├── capabilities.md                  # iOS capabilities configuration
├── icon.md                          # App icon design notes
├── price.md                         # IAP pricing strategy
├── improvement_plan_1.md            # Code generation summary
├── nowgit.md                        # This file
├── keytext.md                       # ⚠️ EXCLUDED (.gitignore — confidential ASO strategy)
└── COMPETITOR_REPORT.md              # ⚠️ EXCLUDED (.gitignore — confidential competitor analysis)
```

## Build Verification

| Platform | Build | Run Test | Status |
|----------|-------|----------|--------|
| iPhone 16 (iOS 26.4) | ✅ SUCCEEDED | ✅ Launched | PASS |
| iPad Pro 13-inch (M5) | ✅ SUCCEEDED | ✅ Launched | PASS |
| Widget Extension | ✅ Embedded | N/A | PASS |

## Security Check

- ✅ No hardcoded API keys in Swift files
- ✅ No credential URLs in code
- ✅ All "password" references are legitimate WiFi password handling (KeychainService)
- ✅ `.env` excluded from git
- ✅ `keytext*.md` excluded (ASO strategy)
- ✅ `COMPETITOR_REPORT.md` excluded (competitor analysis)
- ✅ `TR-*.MD` excluded (Chinese operation guide source)

## IAP Product IDs

| Product | ID | Price |
|---------|-----|-------|
| Monthly Subscription | `com.zzoutuo.WiBeam.pro.monthly` | $1.99/mo (7-day trial) |
| Annual Subscription | `com.zzoutuo.WiBeam.pro.annual` | $14.99/yr |
| Lifetime Purchase | `com.zzoutuo.WiBeam.lifetime` | $9.99 |
