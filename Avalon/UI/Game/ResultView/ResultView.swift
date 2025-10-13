import SwiftUI

struct ResultView: View {
    @Environment(GameStore.self) private var store
    let questID: UUID

    private var quest: QuestViewData? { store.quest(id: questID) }

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("resultView.success.label")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Text("\((quest?.requiredTeamSize ?? 0) - (quest?.result?.failCount ?? 0))")
                        .font(.body.bold())
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.green))
                        .foregroundColor(.white)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                }

                VStack(spacing: 4) {
                    Text("resultView.fail.label")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Text("\(quest?.result?.failCount ?? 0)")
                        .font(.body.bold())
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.red))
                        .foregroundColor(.white)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                }

                if let result = quest?.result?.type, let requiredFail = quest?.requiredFails {
                    VStack(spacing: 4) {
                        Text(String(
                            localized: requiredFail == 1
                                ? "resultView.failRequired.singular.label"
                                : "resultView.failRequired.plural.label"
                        ).replacingOccurrences(of: "%d", with: "\(requiredFail)"))
                            .font(.caption)
                            .foregroundColor(.primary)

                        Text(result.displayText)
                            .font(.body.bold())
                            .frame(height: 40)
                            .padding(.horizontal, 16)
                            .foregroundColor(.white)
                            .background(
                                Capsule()
                                    .fill(result.color)
                                    .shadow(radius: 4)
                            )
                            .accessibilityLabel(result.accessibilityLabel)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let game = GameViewData(game: AvalonGame.random())
    let quest = game.quests[0]
    let store = GameStore(game: game)
    ResultView(questID: quest.id)
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
