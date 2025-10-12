import SwiftUI

struct ResultView: View {
    @Environment(GameStore.self) private var store
    let questID: UUID

    private var quest: QuestViewData? { store.quest(id: questID) }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Success")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Text("\((quest?.requiredTeamSize ?? 0) - (quest?.result?.failVotes ?? 0))")
                        .font(.title2.bold())
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(.green))
                        .foregroundColor(.white)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                }

                VStack(spacing: 4) {
                    Text("Fail")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Text("\(quest?.result?.failVotes ?? 0)")
                        .font(.title2.bold())
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(.red))
                        .foregroundColor(.white)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                }

                if let result = quest?.result?.type, let requiredFail = quest?.requiredFails {
                    VStack(spacing: 4) {
                        Text("\(requiredFail) Fail\(requiredFail == 1 ? "" : "s") Required")
                            .font(.caption)
                            .foregroundColor(.primary)

                        Text(result.displayText)
                            .font(.headline)
                            .frame(height: 48)
                            .padding(.horizontal, 24)
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
