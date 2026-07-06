import SwiftUI
import StoreKit

struct QRDisplayView: View {
    @StateObject private var viewModel: QRDisplayViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false
    @State private var showingStylePicker = false
    @State private var showingPrintSheet = false
    @State private var posterTitle: String = ""

    init(network: WiFiNetworkEntity) {
        _viewModel = StateObject(wrappedValue: QRDisplayViewModel(network: network))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.largeSpacing) {
                    qrDisplaySection

                    networkInfoCard

                    actionButtons

                    if viewModel.purchaseManager.isPro {
                        proFeaturesSection
                    }
                }
                .padding(.horizontal, AppTheme.standardSpacing)
                .padding(.bottom, 40)
            }
            .navigationTitle(viewModel.network.ssid ?? "WiFi QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(AppTheme.primary)
            .task {
                await viewModel.loadPasswordAndGenerate()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(viewModel.purchaseManager)
            }
            .sheet(isPresented: $showingStylePicker) {
                stylePickerSheet
            }
            .alert("Print Poster", isPresented: $showingPrintSheet) {
                TextField("Title (optional)", text: $posterTitle)
                Button("Cancel", role: .cancel) {}
                Button("Print") {
                    if let pdfData = viewModel.generatePosterPDF(title: posterTitle.isEmpty ? "Connect to WiFi" : posterTitle) {
                        ShareService.printPDF(pdfData)
                    }
                }
            } message: {
                Text("Enter a title for your printable QR poster. You can AirPrint or save as PDF.")
            }
            .overlay {
                if viewModel.showSavedToast {
                    toastView(message: "Saved to Photos", icon: "checkmark.circle.fill")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if viewModel.showSharedToast {
                    toastView(message: "Shared successfully", icon: "arrowshape.turn.up.right.fill")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private var qrDisplaySection: some View {
        VStack(spacing: AppTheme.standardSpacing) {
            ZStack {
                RadialGradient(
                    colors: [AppTheme.primary.opacity(0.15), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: 180
                )
                .frame(width: 320, height: 320)

                if let qrImage = viewModel.qrImage {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .qrGenerationAnimation()
                } else {
                    ProgressView()
                        .frame(width: 280, height: 280)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Text("Scan to connect WiFi")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private var networkInfoCard: some View {
        VStack(spacing: 12) {
            infoRow(label: "Network", value: viewModel.network.ssid ?? "—", icon: "wifi")
            infoRow(label: "Security", value: viewModel.network.securityType.displayName, icon: viewModel.network.securityType.systemImage)

            if viewModel.network.isHidden {
                infoRow(label: "Visibility", value: "Hidden", icon: "eye.slash")
            }

            if !viewModel.password.isEmpty {
                HStack {
                    Label("Password", systemImage: "key.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.password)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                }
            }

            if let shareCount = viewModel.network.shareCount as NSNumber?, shareCount.intValue > 0 {
                infoRow(label: "Shared", value: "\(shareCount.intValue) times", icon: "arrowshape.turn.up.right.fill")
            }
        }
        .padding(AppTheme.standardSpacing)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }

    private func infoRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                actionButton(title: "Share", icon: "square.and.arrow.up") {
                    viewModel.shareQR { _ in }
                }

                actionButton(title: "Save", icon: "square.and.arrow.down") {
                    viewModel.saveToPhotos { _ in }
                }
            }

            if viewModel.purchaseManager.isPro {
                actionButton(title: "Print Poster", icon: "printer", full: true) {
                    showingPrintSheet = true
                }
            }
        }
    }

    private var proFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pro Features", systemImage: "crown.fill")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundColor(AppTheme.warning)

            Button {
                showingStylePicker = true
            } label: {
                HStack {
                    Label("Custom QR Style", systemImage: "paintpalette")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(BouncyButtonStyle())
            .tint(.primary)
        }
    }

    private var stylePickerSheet: some View {
        NavigationStack {
            Form {
                Section("Foreground Color") {
                    ColorPicker("QR Foreground", selection: $viewModel.customForegroundColor)
                }
                Section("Background Color") {
                    ColorPicker("QR Background", selection: $viewModel.customBackgroundColor)
                }
                Section {
                    Button("Apply Style") {
                        AppSettings.customStyleEnabled = true
                        AppSettings.customForegroundColorHex = viewModel.customForegroundColor.hexString
                        AppSettings.customBackgroundColorHex = viewModel.customBackgroundColor.hexString
                        viewModel.regenerateQR()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()

                    Button("Reset to Default", role: .destructive) {
                        AppSettings.customStyleEnabled = false
                        viewModel.customForegroundColor = .black
                        viewModel.customBackgroundColor = .white
                        viewModel.regenerateQR()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("QR Style")
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppTheme.primary)
        }
    }

    private func actionButton(title: String, icon: String, full: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: full ? .infinity : nil)
                .frame(height: 50)
                .frame(maxWidth: full ? .infinity : nil)
                .padding(.horizontal)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius))
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private func toastView(message: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(message)
                .font(.system(.subheadline, design: .rounded).bold())
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .foregroundColor(.white)
        .clipShape(Capsule())
        .padding(.bottom, 30)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showSavedToast || viewModel.showSharedToast)
    }
}
