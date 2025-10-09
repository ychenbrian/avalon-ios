import SwiftUI

struct TeamDetailView: View {
    @Environment(GameStore.self) private var store
    let roundID: UUID
    let teamID: UUID

    @State private var isEditingTeam = false

    private var team: TeamViewData? { store.team(id: teamID, in: roundID) }

    var body: some View {
        List {
            HStack(alignment: .center, spacing: 8) {
                Text("Leader")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let leader = team?.leader {
                    overlayForPlayer(leader)
                } else {
                    Text("No leader yet").foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Proposed Team")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let members = team?.members.sorted(by: { $0.index < $1.index }),
                   !members.isEmpty
                {
                    HStack(spacing: 6) {
                        ForEach(members, id: \.id) { player in
                            overlayForPlayer(player)
                        }
                    }
                } else {
                    Text("No members yet")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Votes")
                    .font(.headline)
                    .foregroundColor(.primary)
                VStack(alignment: .leading, spacing: 4) {
                    let rows = playerRows()
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 6) {
                            ForEach(row, id: \.id) { player in
                                overlayForPlayer(player)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        .sheet(isPresented: $isEditingTeam) {
            NavigationStack {}
        }
    }

    private func overlayForPlayer(_ player: Player) -> some View {
        let vote = team?.votesByVoter[player]
        return AnyView(
            PlayerCircle(name: "\(player.index + 1)")
                .overlay(
                    Circle()
                        .stroke(vote == .approve ? .green : (vote == .reject ? .red : .gray), lineWidth: 3)
                )
                .opacity(vote == nil ? 0.5 : 1)
                .overlay(
                    vote == .approve ?
                        Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .offset(x: 12, y: 12) : nil
                )
                .overlay(
                    vote == .reject ?
                        Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .offset(x: 12, y: 12) : nil
                )
        )
    }

    private func playerRows() -> [[Player]] {
        var rows: [[Player]] = []
        var index = 0
        while index < store.players.count {
            let end = min(index + 5, store.players.count)
            rows.append(Array(store.players[index ..< end]))
            index = end
        }
        return rows
    }

    public func getPlayersByID(playerIDs: [PlayerID]) -> [Player] {
        store.players
            .filter { playerIDs.contains($0.id) }
            .sorted { $0.index < $1.index }
    }
}

#Preview {
    let game = GameViewData(game: AvalonGame.random())
    let round = game.rounds[0]
    let store = GameStore(game: game)
    TeamDetailView(roundID: round.id, teamID: round.teams.first?.id ?? UUID())
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
