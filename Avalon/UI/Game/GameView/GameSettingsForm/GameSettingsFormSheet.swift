import SwiftUI

struct GameSettingsFormSheet: View {
    let onSave: (_ numOfPlayers: Int?, _ gameName: String) -> Void
    let onCancel: () -> Void
    let onNewGame: () -> Void

    @State private var draft: GameSettingsFormDraft

    init(
        gameName: String,
        numOfPlayers: Int,
        onSave: @escaping (_ numOfPlayers: Int?, _ gameName: String) -> Void,
        onCancel: @escaping () -> Void,
        onNewGame: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
        self.onNewGame = onNewGame

        let initialDraft = GameSettingsFormDraft(
            gameName: gameName,
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
                    .foregroundStyle(Color.appColor(.primaryTextColor))

                NumberRadioGroup(
                    range: GameRules.numOfPlayerRange,
                    selected: { number in
                        number == draft.updatedNumber
                    },
                    action: { number in
                        draft.setNumberOfPlayers(number)
                    }
                )

                if draft.hasNumOfPlayersUpdate {
                    Text("gameSettingsForm.playerNumber.warning")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.appColor(.failTextColor))
                }

                Divider()
                    .padding()

                Text("gameSettingsForm.gameName.label")
                    .font(.subheadline)
                    .foregroundStyle(Color.appColor(.primaryTextColor))

                let nameBinding = Binding<String>(
                    get: { draft.gameName },
                    set: { newValue in
                        draft.updateGameName(newValue)
                    }
                )

                TextFieldView(
                    text: nameBinding
                )

                Divider()
                    .padding()

                if #available(iOS 26.0, *) {
                    Button {
                        onNewGame()
                    } label: {
                        Text("gameSettingsForm.startNewGame.button")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .buttonStyle(.glassProminent)
                } else {
                    Button {
                        onNewGame()
                    } label: {
                        Text("gameSettingsForm.startNewGame.button")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                }

                Text("gameSettingsForm.startNewGame.warning")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.appColor(.failTextColor))

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
                    .foregroundStyle(Color.appColor(.failTextColor))
                    .accessibilityLabel(String(localized: "gameSettingsForm.cancel.accessibility"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(
                            draft.hasNumOfPlayersUpdate ? draft.updatedNumber : nil,
                            draft.gameName
                        )
                    } label: {
                        Text("gameSettingsForm.save.button")
                    }
                    .foregroundStyle(Color.appColor(.selectedTextColor))
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
            gameName: "Game 1",
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
