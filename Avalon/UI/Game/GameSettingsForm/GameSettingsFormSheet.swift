import SwiftUI

struct GameSettingsFormSheet: View {
    let onSave: (_ numOfPlayers: Int) -> Void
    let onCancel: () -> Void

    @State private var draft: GameSettingsFormDraft

    init(
        numOfPlayers: Int,
        onSave: @escaping (_ numOfPlayers: Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel

        let initialDraft = GameSettingsFormDraft(numOfPlayers: numOfPlayers)

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("gameSettingsForm.playerNumber.label")
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

                Text("gameSettingsForm.playerNumber.warning")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("gameSettingsForm.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Text("gameSettingsForm.cancel.button")
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel(String(localized: "gameSettingsForm.cancel.accessibility"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(draft.numOfPlayers)
                    } label: {
                        Text("gameSettingsForm.save.button")
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel(String(localized: "gameSettingsForm.save.accessibility"))
                }
            }
            .interactiveDismissDisabled(false)
        }
    }
}

struct GameSettingsFormSheetPreview: View {
    var body: some View {
        GameSettingsFormSheet(
            numOfPlayers: 10,
            onSave: { _ in },
            onCancel: {}
        )
        .presentationDetents([.medium])
    }
}

#Preview {
    GameSettingsFormSheetPreview()
}
