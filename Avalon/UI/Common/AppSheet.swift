import SwiftUI

// 1) A request model the router can carry around.
struct TextEntryRequest: Identifiable {
    let id = UUID()
    var title: String
    var message: String? = nil
    var defaultText: String = ""
    var placeholder: String = ""
    var submitTitle: String = "Done"
    var allowEmpty: Bool = false
    var charLimit: Int? = nil
    var onSubmit: (String) -> Void
}

// 2) Shared router you inject once at the root.
@Observable final class SheetRouter {
    var textEntry: TextEntryRequest?

    func prompt(
        _ title: String,
        message: String? = nil,
        defaultText: String = "",
        placeholder: String = "",
        submitTitle: String = "Done",
        allowEmpty: Bool = false,
        charLimit: Int? = nil,
        onSubmit: @escaping (String) -> Void
    ) {
        textEntry = TextEntryRequest(
            title: title,
            message: message,
            defaultText: defaultText,
            placeholder: placeholder,
            submitTitle: submitTitle,
            allowEmpty: allowEmpty,
            charLimit: charLimit,
            onSubmit: onSubmit
        )
    }

    func dismiss() { textEntry = nil }
}

// 3) The actual sheet UI: TextField + toolbar actions.
struct TextEntrySheetView: View {
    let req: TextEntryRequest
    @State private var text: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    init(req: TextEntryRequest) {
        self.req = req
        _text = State(initialValue: req.defaultText)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let msg = req.message {
                    Text(msg).font(.subheadline).foregroundStyle(.secondary)
                }

                TextField(req.placeholder, text: $text)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit(submit)

                if let limit = req.charLimit {
                    HStack {
                        Spacer()
                        Text("\(text.count)/\(limit)")
                            .foregroundStyle(text.count > limit ? .red : .secondary)
                    }
                }
            }
            .navigationTitle(req.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(req.submitTitle, action: submit)
                        .disabled(isDisabled)
                }
            }
        }
        .onAppear { DispatchQueue.main.async { focused = true } }
        .presentationDetents([.fraction(0.33), .medium]) // small, but can expand if needed
        .presentationDragIndicator(.visible)
    }

    private var isDisabled: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !req.allowEmpty, trimmed.isEmpty { return true }
        if let limit = req.charLimit, text.count > limit { return true }
        return false
    }

    private func submit() {
        req.onSubmit(text)
        dismiss()
    }
}
