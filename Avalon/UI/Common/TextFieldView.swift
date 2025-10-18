import SwiftUI

struct TextFieldView: View {
    @Binding var text: String
    var placeholder: String = "Enter the text"
    var icon: Image = .init(systemName: "pencil")

    var body: some View {
        HStack {
            icon
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
