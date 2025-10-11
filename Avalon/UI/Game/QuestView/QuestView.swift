import SwiftUI

struct QuestView: View {
    @Environment(GameStore.self) private var store
    let roundID: UUID

    private var round: RoundViewData? { store.round(id: roundID) }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Success")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Text("\((round?.requiredTeamSize ?? 0) - (round?.quest?.failVotes ?? 0))")
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
                    Text("\(round?.quest?.failVotes ?? 0)")
                        .font(.title2.bold())
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(.red))
                        .foregroundColor(.white)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                }

                if let result = round?.quest?.result, let requiredFail = round?.requiredFails {
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
    let round = game.rounds[0]
    let store = GameStore(game: game)
    QuestView(roundID: round.id)
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
