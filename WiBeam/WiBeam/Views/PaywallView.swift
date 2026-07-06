import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    private let policyBaseURL = "https://asunnyboy861.github.io/WiBeam"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.largeSpacing) {
                    heroSection

                    featuresSection

                    plansSection

                    legalSection
                }
                .padding(.horizontal, AppTheme.standardSpacing)
                .padding(.bottom, 40)
            }
            .navigationTitle("WiBeam Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .tint(AppTheme.primary)
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK") {}
            } message: {
                Text(restoreMessage)
            }
            .alert("Purchase Error", isPresented: Binding(
                get: { purchaseError != nil },
                set: { if !$0 { purchaseError = nil } }
            )) {
                Button("OK") { purchaseError = nil }
            } message: {
                Text(purchaseError ?? "")
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.warning)
            }
            .padding(.top, 20)

            Text("Unlock WiBeam Pro")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(.primary)

            Text("Remove limits, sync across devices,\nand access premium features.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("Unlimited WiFi networks", icon: "infinity")
            featureRow("iCloud sync across devices", icon: "icloud.fill")
            featureRow("Home screen widget", icon: "rectangle.on.rectangle")
            featureRow("Custom QR colors & logo", icon: "paintpalette.fill")
            featureRow("Biometric app lock", icon: "faceid")
            featureRow("Print QR posters", icon: "printer.fill")
            featureRow("Timed access QR codes", icon: "clock.fill")
            featureRow("Batch share", icon: "square.and.arrow.up.on.square")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }

    private func featureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
        }
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            if purchaseManager.isLoading {
                ProgressView("Loading plans...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if purchaseManager.products.isEmpty {
                Text("Plans unavailable. Please try again later.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(purchaseManager.products, id: \.id) { product in
                    planCard(product)
                }
            }
        }
    }

    private func planCard(_ product: Product) -> some View {
        let isLifetime = product.id == PurchaseManager.lifetimeID
        let isAnnual = product.id == PurchaseManager.annualID
        let isMonthly = product.id == PurchaseManager.monthlyID

        return Button {
            selectedProduct = product
            Task { await purchase(product) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(product.displayName)
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(.primary)

                        if isAnnual {
                            badge("BEST VALUE", color: AppTheme.success)
                        } else if isLifetime {
                            badge("POPULAR", color: AppTheme.warning)
                        } else if isMonthly {
                            badge("7-DAY TRIAL", color: AppTheme.primary)
                        }
                    }

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundColor(AppTheme.primary)

                        if isMonthly {
                            Text("/ month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if isAnnual {
                            Text("/ year")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if isLifetime {
                            Text("one-time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if isMonthly {
                        Text("7-day free trial, then \(product.displayPrice)/month")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else if isAnnual {
                        Text("Save 37% vs monthly")
                            .font(.caption2)
                            .foregroundColor(AppTheme.success)
                    }
                }

                Spacer()

                if isPurchasing && selectedProduct?.id == product.id {
                    ProgressView()
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke((selectedProduct?.id == product.id) ? AppTheme.primary : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(isPurchasing)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(.caption2, design: .rounded).bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private var legalSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await purchaseManager.restorePurchases()
                    restoreMessage = purchaseManager.isPro ? "Pro features unlocked!" : "No previous purchases found."
                    showRestoreAlert = true
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundColor(AppTheme.primary)
            }
            .buttonStyle(BouncyButtonStyle())

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "\(policyBaseURL)/privacy.html")!)
                Text("·").foregroundColor(.secondary)
                Link("Terms of Use", destination: URL(string: "\(policyBaseURL)/terms.html")!)
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text("Cancel anytime in Settings → Apple ID → Subscriptions.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await purchaseManager.purchase(product)
            if purchaseManager.isPro {
                dismiss()
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager.shared)
}
