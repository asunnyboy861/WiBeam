import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubject: String = "General"
    @State private var customSubject: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSending = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "WiBeam"

    private let subjects = [
        "General",
        "Feature Suggestion",
        "Bug Report",
        "Usage Question",
        "Performance Issue",
        "UI Improvement",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                        ForEach(subjects, id: \.self) { subject in
                            Button {
                                selectedSubject = subject
                            } label: {
                                Text(subject)
                                    .font(.subheadline)
                                    .fontWeight(selectedSubject == subject ? .semibold : .regular)
                                    .foregroundStyle(selectedSubject == subject ? .white : .primary)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSubject == subject ? AppTheme.primary : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)

                    if selectedSubject == "Other" {
                        TextField("Please specify your topic", text: $customSubject)
                            .textInputAutocapitalization(.sentences)
                    }
                }

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
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if isSending {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Send Message")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .padding(.vertical, 4)
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
            .alert("Could Not Send Message", isPresented: $showErrorAlert) {
                Button("Try Again") {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var finalSubject: String {
        if selectedSubject == "Other" {
            return customSubject.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedSubject
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !finalSubject.isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submit() async {
        isSending = true
        defer { isSending = false }

        guard let url = URL(string: "\(backendURL)/api/feedback") else {
            errorMessage = "We couldn't reach our support server. Please try again later."
            showErrorAlert = true
            return
        }

        let feedback = FeedbackRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            subject: finalSubject,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            app_name: appName
        )

        do {
            let requestBody = try JSONEncoder().encode(feedback)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                showSuccessAlert = true
            } else {
                errorMessage = "Our support server is temporarily unavailable. Please try again in a moment."
                showErrorAlert = true
            }
        } catch {
            errorMessage = "We couldn't connect to our support server. Check your internet connection and try again."
            showErrorAlert = true
        }
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}

#Preview {
    ContactSupportView()
}
