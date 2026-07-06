import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("widgetEnabled") private var widgetEnabled = false
    @State private var showingPaywall = false
    @State private var showingContactSupport = false
    @State private var showingAbout = false

    private let policyBaseURL = "https://asunnyboy861.github.io/WiBeam"

    var body: some View {
        NavigationStack {
            Form {
                proSection

                featuresSection

                supportSection

                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(AppTheme.primary)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchaseManager)
            }
            .sheet(isPresented: $showingContactSupport) {
                ContactSupportView()
            }
            .alert("About WiBeam", isPresented: $showingAbout) {
                Button("OK") {}
            } message: {
                Text("WiBeam version \(appVersion)\n\nShare your WiFi in 3 seconds via QR codes. Cross-platform, secure, and beautifully simple.\n\nMade with care.")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(AppTheme.warning)
                    Text("Pro Active")
                        .font(.system(.body, design: .rounded).bold())
                    Spacer()
                    Text("Thank you!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundColor(AppTheme.warning)
                        VStack(alignment: .leading) {
                            Text("Upgrade to Pro")
                                .font(.system(.body, design: .rounded).bold())
                                .foregroundColor(.primary)
                            Text("Unlock all features")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var featuresSection: some View {
        Section("Features") {
            Toggle(isOn: $biometricLockEnabled) {
                Label("Biometric Lock", systemImage: "faceid")
            }
            .tint(AppTheme.primary)
            .disabled(!purchaseManager.isPro)
            .onChange(of: biometricLockEnabled) { _, newValue in
                if newValue && !purchaseManager.isPro {
                    biometricLockEnabled = false
                    showingPaywall = true
                }
            }

            Toggle(isOn: $iCloudSyncEnabled) {
                Label("iCloud Sync", systemImage: "icloud.fill")
            }
            .tint(AppTheme.primary)
            .disabled(!purchaseManager.isPro)
            .onChange(of: iCloudSyncEnabled) { _, newValue in
                if newValue && !purchaseManager.isPro {
                    iCloudSyncEnabled = false
                    showingPaywall = true
                }
            }

            Toggle(isOn: $widgetEnabled) {
                Label("Home Screen Widget", systemImage: "rectangle.on.rectangle")
            }
            .tint(AppTheme.primary)
            .disabled(!purchaseManager.isPro)
            .onChange(of: widgetEnabled) { _, newValue in
                if newValue && !purchaseManager.isPro {
                    widgetEnabled = false
                    showingPaywall = true
                }
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Button {
                showingContactSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope.fill")
            }

            Link(destination: URL(string: "\(policyBaseURL)/support.html")!) {
                Label("Help & FAQ", systemImage: "questionmark.circle")
            }

            Link(destination: URL(string: "\(policyBaseURL)/privacy.html")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }

            Link(destination: URL(string: "\(policyBaseURL)/terms.html")!) {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("\(appVersion)")
                    .foregroundColor(.secondary)
            }

            Button {
                showingAbout = true
            } label: {
                Label("About WiBeam", systemImage: "wifi")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseManager.shared)
}
