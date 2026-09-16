import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss

    enum Subject: String, CaseIterable, Identifiable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case usage = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .general: return "bubble.left.fill"
            case .feature: return "lightbulb.fill"
            case .bug: return "ant.fill"
            case .usage: return "questionmark.circle.fill"
            case .performance: return "gauge.with.dots.needle.67percent"
            case .ui: return "paintpalette.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    @State private var subject: Subject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var feedback: SubmissionFeedback?

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    private let maxMessageLength = 1000

    struct SubmissionFeedback: Identifiable {
        let id = UUID()
        var success: Bool
        var text: String
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                subjectGrid
                if subject == .other {
                    TextField("Custom subject", text: $customSubject)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Name").font(.subheadline.weight(.medium))
                    TextField("Your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").font(.subheadline.weight(.medium))
                    TextField("yourname@example.com", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Message").font(.subheadline.weight(.medium))
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $message)
                            .frame(minHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(DesignSystem.separator)
                            }
                        if message.isEmpty {
                            Text("Tell us what's on your mind…")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    Text("\(message.count) / \(maxMessageLength)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        if isSubmitting { ProgressView().tint(.black) }
                        Text("Submit").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.amber)
                .disabled(!isFormValid || isSubmitting)
                .accessibilityLabel("Submit feedback")

                Text("We only use your email to respond to this feedback.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                if let feedback {
                    Label(feedback.text, systemImage: feedback.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(feedback.success ? .green : .orange)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFormValid: Bool {
        let validSubject = subject != .other || !customSubject.trimmingCharacters(in: .whitespaces).isEmpty
        let emailValid = email.contains("@") && email.contains(".") && email.count > 4
        return validSubject && !name.trimmingCharacters(in: .whitespaces).isEmpty
            && emailValid
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var subjectGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject").font(.subheadline.weight(.medium))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Subject.allCases) { option in
                    subjectTile(option)
                }
            }
        }
    }

    private func subjectTile(_ option: Subject) -> some View {
        let isSelected = subject == option
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { subject = option }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: option.symbol)
                    .font(.title3)
                Text(option.rawValue)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? DesignSystem.amber : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .black : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(DesignSystem.amber, lineWidth: 2)
                }
            }
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Subject: \(option.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let finalSubject = subject == .other
            ? customSubject.trimmingCharacters(in: .whitespaces)
            : subject.rawValue

        struct FeedbackRequest: Codable {
            let name: String
            let email: String
            let subject: String
            let message: String
            let app_name: String
        }

        let payload = FeedbackRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            subject: finalSubject,
            message: message.trimmingCharacters(in: .whitespaces),
            app_name: "Sketcho"
        )

        guard let url = URL(string: backendURL) else {
            feedback = .init(success: false, text: "Something went wrong. Please try again.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                feedback = .init(success: false, text: "Something went wrong. Please try again.")
                return
            }
            _ = data
            feedback = .init(success: true, text: "Thank you! Your feedback has been sent.")
            name = ""
            email = ""
            message = ""
            customSubject = ""
            subject = .general
        } catch {
            feedback = .init(success: false, text: "Something went wrong. Please try again.")
        }
    }
}
