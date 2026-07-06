import SwiftUI
import StoreKit

struct EmptyStateView: View {
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.largeSpacing) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "wifi")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(AppTheme.primary)
                    .rotationEffect(.degrees(-30))
            }

            VStack(spacing: 8) {
                Text("Welcome to WiBeam")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundColor(.primary)

                Text("Share your WiFi in 3 seconds.\nGenerate a QR code, scan, and connect — no typing required.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, AppTheme.standardSpacing)

            Button(action: onAddTapped) {
                Label("Add Your First WiFi", systemImage: "plus.circle.fill")
                    .font(.system(.headline, design: .rounded).bold())
                    .frame(maxWidth: .infinity)
                    .padding()
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

#Preview {
    EmptyStateView(onAddTapped: {})
}
