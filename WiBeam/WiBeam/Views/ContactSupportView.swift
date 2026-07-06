import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var isSending = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    private let appName = "WiBeam"

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section("Subject") {
                    TextField("Brief subject", text: $subject)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Message") {
                    TextField("Tell us how we can help...", text: $message, axis: .vertical)
                        .lineLimit(5...10)
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if isSending {
                                ProgressView()
                            }
                            Text("Send Message")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                    }
                    .disabled(!isFormValid || isSending)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .tint(AppTheme.primary)
            .alert("Message Sent", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you! We'll get back to you within 24 hours.")
            }
            .alert("Send Failed", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() async {
        isSending = true
        defer { isSending = false }

        guard let url = URL(string: backendURL) else {
            errorMessage = "Invalid backend URL."
            showErrorAlert = true
            return
        }

        let payload: [String: Any] = [
            "name": name,
            "email": email,
            "subject": subject,
            "message": message,
            "app_name": appName
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                showSuccessAlert = true
            } else {
                errorMessage = "Server returned an error. Please try again."
                showErrorAlert = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview {
    ContactSupportView()
}
