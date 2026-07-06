import SwiftUI
import PhotosUI

struct AddWiFiView: View {
    @StateObject private var viewModel: AddWiFiViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPassword: Bool = false
    @State private var logoItem: PhotosPickerItem?

    init(editing: WiFiNetworkEntity? = nil, onSaved: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AddWiFiViewModel(editing: editing))
        viewModel.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("WiFi Network") {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(AppTheme.primary)
                        TextField("Network name (SSID)", text: $viewModel.ssid)
                            .textInputAutocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    if let error = viewModel.ssidValidationError, !viewModel.ssid.isEmpty {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppTheme.error)
                    }

                    Picker("Security", selection: $viewModel.security) {
                        ForEach(WiFiSecurity.allCases) { security in
                            Text(security.displayName).tag(security)
                        }
                    }
                    .onChange(of: viewModel.security) { _, _ in
                        viewModel.password = ""
                    }

                    if viewModel.isPasswordRequired {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.primary)
                            if showPassword {
                                TextField("Password", text: $viewModel.password)
                                    .textInputAutocapitalization(.none)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .textInputAutocapitalization(.none)
                            }
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }

                        if let error = viewModel.passwordValidationError, !viewModel.password.isEmpty {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(AppTheme.error)
                        }

                        Text("\(viewModel.password.count)/\(viewModel.security.maxLength) characters")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Toggle("Hidden network", isOn: $viewModel.isHidden)
                        .tint(AppTheme.primary)
                }

                Section("Notes") {
                    TextField("Optional note (e.g., 'Home', 'Office')", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                }

                if viewModel.purchaseManager.isPro {
                    Section("Custom Branding (Pro)") {
                        ColorPicker("Network color", selection: $viewModel.brandColor)

                        PhotosPicker(selection: $logoItem, matching: .images) {
                            Label("Choose logo", systemImage: "photo.badge.plus")
                        }

                        if viewModel.logoData != nil {
                            Button("Remove logo", role: .destructive) {
                                viewModel.logoData = nil
                            }
                        }

                        DisclosureGroup("Timed Access") {
                            Toggle("Set expiry date", isOn: Binding(
                                get: { viewModel.expiryDate != nil },
                                set: { newValue in
                                    viewModel.expiryDate = newValue ? Date().addingTimeInterval(3600) : nil
                                }
                            ))
                            .tint(AppTheme.primary)

                            if viewModel.expiryDate != nil {
                                DatePicker("Expires", selection: Binding(
                                    get: { viewModel.expiryDate ?? Date() },
                                    set: { viewModel.expiryDate = $0 }
                                ), in: Date()...)
                            }
                        }
                    }
                }

                if let error = viewModel.error {
                    Section {
                        Text(error)
                            .foregroundColor(AppTheme.error)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit WiFi" : "Add WiFi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.save() {
                            dismiss()
                        }
                    } label: {
                        Text(viewModel.isEditing ? "Update" : "Save")
                            .bold()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .tint(AppTheme.primary)
            .task {
                await viewModel.loadExistingPassword()
            }
            .onChange(of: logoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.logoData = data
                    }
                }
            }
        }
    }
}
