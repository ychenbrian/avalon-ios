import SwiftUI

struct GameFormSheet: View {
    let onSave: (_ numOfPlayers: Int) -> Void
    let onCancel: () -> Void

    @State private var draft: GameFormDraft

    init(
        numOfPlayers: Int,
        onSave: @escaping (_ numOfPlayers: Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel

        let initialDraft = GameFormDraft(numOfPlayers: numOfPlayers)

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("gameForm.playerNumber.label")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                NumberRadioGroup(
                    range: GameRules.defaultTeamSizeRange,
                    selected: { number in
                        number == draft.numOfPlayers
                    },
                    action: { number in
                        draft.numOfPlayers = number
                    }
                )

                Text("gameForm.playerNumber.warning")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("gameForm.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Text("gameForm.cancel.button")
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel(String(localized: "gameForm.cancel.accessibility"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(draft.numOfPlayers)
                    } label: {
                        Text("gameForm.save.button")
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel(String(localized: "gameForm.save.accessibility"))
                }
            }
            .interactiveDismissDisabled(false)
        }
    }
}

struct GameFormSheetPreview: View {
    var body: some View {
        GameFormSheet(
            numOfPlayers: 10,
            onSave: { _ in },
            onCancel: {}
        )
        .presentationDetents([.medium])
    }
}

#Preview {
    GameFormSheetPreview()
}
