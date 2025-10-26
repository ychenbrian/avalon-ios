import SwiftUI

struct GameCellView: View {
    let game: DBModel.Game

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading) {
                HStack {
                    Text(game.name.isEmpty ? String(localized: "game.untitledGame") : game.name)

                    Spacer()

                    if let result = game.result {
                        GameResultView(result: result)
                    }
                }

                HStack {
                    if game.finishedAt != nil {
                        Text(game.finishedAt?.toHourMinute() ?? "-")
                            .foregroundColor(.secondary)
                    } else {
                        Text(game.startedAt?.toHourMinute() ?? "-")
                            .foregroundColor(.secondary)
                    }

                    Text(localizedPlayerCount())
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    private func localizedPlayerCount() -> String {
        let count = game.players.count
        let key = count == 1 ? "historyView.gameCell.numOfPlayer.singular" : "historyView.gameCell.numOfPlayer.plural"
        return key.localizedWithArguments(arguments: [count])
    }
}

#Preview {
    GameCellView(
        game: .empty(finishedAt: "2025-10-26T15:45:00Z", result: .goodWinByFailedAss)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
