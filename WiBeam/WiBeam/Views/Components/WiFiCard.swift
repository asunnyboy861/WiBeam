import SwiftUI

struct WiFiCard: View {
    let network: WiFiNetworkEntity
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void

    @State private var showContextMenu: Bool = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.standardSpacing) {
                ZStack {
                    Circle()
                        .fill(Color(hex: network.brandColor ?? "#0080FF").opacity(0.15))
                        .frame(width: 48, height: 48)

                    Text(network.displayInitial)
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(Color(hex: network.brandColor ?? "#0080FF"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(network.ssid ?? "Unknown")
                            .font(.system(.body, design: .rounded).bold())
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if network.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.warning)
                        }

                        if network.hasExpiry {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(network.isExpired ? AppTheme.error : AppTheme.warning)
                        }
                    }

                    HStack(spacing: 8) {
                        Label(network.securityType.displayName, systemImage: network.securityType.systemImage)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if network.isHidden {
                            Label("Hidden", systemImage: "eye.slash")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if network.shareCount > 0 {
                            Label("\(network.shareCount)", systemImage: "arrowshape.turn.up.right.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "qrcode")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(AppTheme.standardSpacing)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel("\(network.ssid ?? "WiFi") network")
        .accessibilityHint("Tap to display QR code")
        .accessibilityAddTraits(.isButton)
        .contextMenu {
            Button {
                onToggleFavorite()
            } label: {
                Label(network.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: network.isFavorite ? "star.slash" : "star")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
