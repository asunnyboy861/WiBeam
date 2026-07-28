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
    private let supportEmail = "iocompile67692@gmail.com"
    private let privacyURL = "https://asunnyboy861.github.io/WiBeam/privacy.html"
    private let appName = "WiBeam"
    private let maxMessageLength = 2000

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Information") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section("Subject") {
                    TextField("Brief subject", text: $subject)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if message.isEmpty {
                                Text("Tell us how we can help...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                    Text("\(message.count)/\(maxMessageLength)")
                        .font(.caption)
                        .foregroundStyle(message.count > maxMessageLength ? .red : .secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
                } footer: {
                    privacyFooter
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
            .alert("Could Not Send Message", isPresented: $showErrorAlert) {
                Button("Try Again") {}
                Button("Email Us") {
                    openMailto()
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var privacyFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("By sending a message, you agree to share your name, email, subject, and message with our support team so we can respond to your inquiry. We do not use your information for marketing or share it with third parties.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Link(destination: URL(string: privacyURL)!) {
                Text("Read our Privacy Policy")
                    .font(.caption)
            }
        }
    }

    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespaces)
        let trimmedMessage = message.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedSubject.isEmpty,
              !trimmedMessage.isEmpty,
              message.count <= maxMessageLength else {
            return false
        }

        return isValidEmail(trimmedEmail)
    }

    private func isValidEmail(_ address: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: address)
    }

    private func submit() async {
        isSending = true
        defer { isSending = false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address so we can reply to you."
            showErrorAlert = true
            return
        }

        guard let url = URL(string: backendURL) else {
            errorMessage = "We couldn't reach our support server. Please try again or email us directly."
            showErrorAlert = true
            return
        }

        let payload: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": trimmedEmail,
            "subject": subject.trimmingCharacters(in: .whitespaces),
            "message": message.trimmingCharacters(in: .whitespacesAndNewlines),
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
                errorMessage = "Our support server is temporarily unavailable. Please try again in a moment or email us directly."
                showErrorAlert = true
            }
        } catch {
            errorMessage = "We couldn't connect to our support server. Check your internet connection, try again, or email us directly."
            showErrorAlert = true
        }
    }

    private func openMailto() {
        let body = "\n\n---\nApp: \(appName)\nFrom: \(name) <\(email)>"
        let subjectEncoded = "WiBeam Support Request".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        if let url = URL(string: "mailto:\(supportEmail)?subject=\(subjectEncoded)&body=\(bodyEncoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContactSupportView()
}
