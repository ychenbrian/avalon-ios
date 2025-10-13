import SwiftUI

struct GameSettingsFormSheet: View {
    let onSave: (_ numOfPlayers: Int, _ hasUpdated: Bool) -> Void
    let onCancel: () -> Void
    let onNewGame: () -> Void

    @State private var draft: GameSettingsFormDraft

    init(
        numOfPlayers: Int,
        onSave: @escaping (_ numOfPlayers: Int, _ hasUpdated: Bool) -> Void,
        onCancel: @escaping () -> Void,
        onNewGame: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
        self.onNewGame = onNewGame

        let initialDraft = GameSettingsFormDraft(
            numOfPlayers: numOfPlayers,
            updatedNumber: numOfPlayers
        )

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
                        number == draft.updatedNumber
                    },
                    action: { number in
                        draft.setNumberOfPlayers(number)
                    }
                )

                if draft.hasUpdated {
                    Text("gameSettingsForm.playerNumber.warning")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.red)
                }

                Divider()
                    .padding()

                Button {
                    onNewGame()
                } label: {
                    Text("gameSettingsForm.startNewGame.button")
                }
                .font(.headline)
                .foregroundColor(.white)
                .buttonStyle(.glassProminent)

                Text("gameSettingsForm.startNewGame.warning")
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
                        onSave(
                            draft.updatedNumber,
                            draft.hasUpdated
                        )
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
            onSave: { _, _ in },
            onCancel: {},
            onNewGame: {}
        )
        .presentationDetents([.medium])
    }
}

#Preview {
    GameSettingsFormSheetPreview()
}
