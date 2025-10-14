import SwiftUI

struct GameFinishFormSheet: View {
    let onFinish: (_ result: GameResult?) -> Void

    @State private var draft: GameFinishFormDraft

    init(
        status: GameStatus,
        result: GameResult?,
        onFinish: @escaping (_ result: GameResult?) -> Void
    ) {
        self.onFinish = onFinish

        let initialDraft = GameFinishFormDraft(status: status, result: result)

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack {
                GameFinishRadioGroup(
                    texts: getResultOptions(),
                    selected: { text in
                        text == draft.result?.displayText
                    },
                    action: { text in
                        draft.result = GameResult(displayText: text)
                    }
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle(getTitleString())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onFinish(draft.result)
                    } label: {
                        Text("gameFinishForm.finish.button")
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel(String(localized: "gameFinishForm.finish.accessibility"))
                }
            }
            .interactiveDismissDisabled(true)
        }
    }

    private func getTitleString() -> String {
        if draft.status == .threeSuccesses {
            return String(localized: "gameFinishForm.threeSuccess.label")
        } else if draft.status == .threeFails {
            return String(localized: "gameFinishForm.threeSuccess.label")
        } else if draft.status == .earlyAssassin {
            return String(localized: "gameFinishForm.earlyAssassin.label")
        }
        return String(localized: "gameFinishForm.title")
    }

    private func getResultOptions() -> [String] {
        if draft.status == .threeSuccesses || draft.status == .earlyAssassin {
            return [
                GameResult.goodWinByFailedAss.displayText,
                GameResult.evilWinByAssassin.displayText,
            ]
        } else if draft.status == .threeFails {
            return [
                GameResult.evilWinByQuest.displayText,
            ]
        }
        return []
    }
}

struct GameFinishFormSheetPreview: View {
    var body: some View {
        GameFinishFormSheet(
            status: .threeSuccesses,
            result: nil,
            onFinish: { _ in }
        )
        .presentationDetents([.medium])
    }
}

#Preview {
    GameFinishFormSheetPreview()
}
