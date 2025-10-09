import SwiftUI

struct DemoPopupView: View {
    @State private var showDialog = false
    @State private var name = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Button("Show custom dialog") { showDialog = true }
        }
        .padding()
        .popup(isPresented: $showDialog, tapOutsideToDismiss: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Create Customer")
                    .font(.headline)

                Text("Enter a display name. You can change this later.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                TextField("Customer name", text: $name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .focused($nameFocused)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                HStack {
                    Button(role: .cancel) {
                        showDialog = false
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }

                    Button {
                        // Do your action (e.g., save)
                        print("Create: \(name)")
                        showDialog = false
                    } label: {
                        Text("Create")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .buttonStyle(.bordered)
            }
            .background()
            .onAppear { nameFocused = true } // focus the field
        }
    }
}

#Preview {
    DemoPopupView()
}
