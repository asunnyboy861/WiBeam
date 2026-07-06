import SwiftUI
import LocalAuthentication

@main
struct WiBeamApp: App {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLocked: Bool = false
    @State private var lastBackgroundDate: Date?

    var body: some Scene {
        WindowGroup {
            Group {
                if isLocked && AppSettings.biometricLockEnabled {
                    LockScreenView(onUnlock: { isLocked = false })
                } else {
                    ContentView()
                }
            }
            .environmentObject(purchaseManager)
            .tint(AppTheme.primary)
            .onAppear {
                if AppSettings.biometricLockEnabled {
                    authenticate()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleSceneChange(newPhase)
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    private func handleSceneChange(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            if AppSettings.biometricLockEnabled {
                lastBackgroundDate = Date()
            }
        case .active:
            if AppSettings.biometricLockEnabled,
               let lastBackgroundDate,
               Date().timeIntervalSince(lastBackgroundDate) > 30 {
                isLocked = true
                authenticate()
            }
        @unknown default:
            break
        }
    }

    private func authenticate() {
        guard AppSettings.biometricLockEnabled else { return }
        Task {
            let success = await BiometricService.authenticate(reason: "Unlock WiBeam to access your WiFi networks")
            await MainActor.run {
                if success {
                    isLocked = false
                }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "wibeam" else { return }
        if url.host == "wifi" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let uuidString = components.queryItems?.first(where: { $0.name == "id" })?.value,
               let _ = UUID(uuidString: uuidString) {
                AppGroupConfig.userDefaults?.set(uuidString, forKey: AppGroupConfig.lastWiFiUUIDKey)
                AppSettings.lastSelectedWiFiUUID = uuidString
            }
        }
    }
}

struct LockScreenView: View {
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.largeSpacing) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.primary)
            }

            Text("WiBeam Locked")
                .font(.system(.title, design: .rounded).bold())

            Text("Authenticate to continue")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)

            Button {
                Task {
                    let success = await BiometricService.authenticate(reason: "Unlock WiBeam to access your WiFi networks")
                    if success {
                        onUnlock()
                    }
                }
            } label: {
                Label("Unlock", systemImage: "faceid")
                    .font(.system(.headline, design: .rounded).bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius))
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
