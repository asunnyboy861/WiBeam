# Pricing Configuration

## Monetization Model: Freemium with IAP

WiBeam is free to download with a 3-network limit. Users can unlock unlimited networks and Pro features via one-time lifetime purchase or auto-renewable subscriptions (monthly/annual). No AI features, no API costs — sustainable for lifetime pricing.

## Subscription Group
- **Group Name**: WiBeam Premium
- **Reference Name**: WiBeam Premium
- **Products in group**: WiBeam Pro Monthly, WiBeam Pro Annual

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: WiBeam Pro Monthly
- **Product ID**: `com.zzoutuo.WiBeam.pro.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $1.99 USD per month
- **Display Name**: `WiBeam Pro Monthly` (18 chars, ≤35 ✅)
- **Description**: `Unlimited networks, iCloud sync, widget, colors.` (49 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: WiBeam Premium
- **Restore Purchases**: ✅ Required

### 2. Yearly Subscription
- **Reference Name**: WiBeam Pro Annual
- **Product ID**: `com.zzoutuo.WiBeam.pro.annual`
- **Type**: Auto-renewable subscription
- **Price**: $14.99 USD per year (37% savings vs monthly)
- **Display Name**: `WiBeam Pro Annual` (17 chars, ≤35 ✅)
- **Description**: `All Pro features. Best value — save 37%!` (40 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: WiBeam Premium (same group as monthly)
- **Restore Purchases**: ✅ Required

### 3. Lifetime Purchase
- **Reference Name**: WiBeam Lifetime
- **Product ID**: `com.zzoutuo.WiBeam.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $9.99 USD (one-time)
- **Display Name**: `WiBeam Lifetime` (15 chars, ≤35 ✅)
- **Description**: `Pay once, use forever. All Pro features unlocked.` (49 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Note**: Sustainable — no ongoing API/server costs for this app.

## Free Tier (Default)

- **Price**: Free
- **Features**:
  - WiFi QR code generation (unlimited)
  - Manual WiFi info entry
  - QR code save to Photos
  - Basic share (system share sheet)
  - Up to 3 WiFi networks stored
  - QR code scan (via iOS native camera)
- **Conversion hooks**:
  - 4th WiFi add attempt → Paywall
  - Widget toggle in Settings → Paywall
  - iCloud Sync toggle in Settings → Paywall
  - Custom Style button on QR display → Paywall

## Pro Features Unlocked (All Tiers)

| Feature | Free | Pro |
|---------|:----:|:---:|
| WiFi QR code generation | ✅ Unlimited | ✅ Unlimited |
| QR code save to Photos | ✅ | ✅ |
| Basic share (AirDrop/Messages/Email) | ✅ | ✅ |
| WiFi networks stored | 3 max | ✅ Unlimited |
| iCloud sync across devices | ❌ | ✅ |
| WidgetKit home screen widget | ❌ | ✅ |
| Custom QR colors & logo embed | ❌ | ✅ |
| Biometric lock (Face ID/Touch ID) | ❌ | ✅ |
| Timed access QR codes | ❌ | ✅ |
| Print poster (AirPrint + PDF) | ❌ | ✅ |
| Batch share | ❌ | ✅ |
| No ads | ✅ (no ads in free) | ✅ |

## Free Trial
- **Duration**: 7 days
- **Type**: Introductory offer (auto-converts to paid monthly subscription)
- **Available for**: Monthly subscription only
- **Disclosure**: "7-day free trial, then $1.99/month. Cancel anytime in Settings → Apple ID → Subscriptions."

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions)
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page
- [x] Pricing clearly stated in PaywallView
- [x] Free trial terms included (7-day on Monthly)
- [x] Restore purchases functionality implemented
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
