import SwiftUI

struct RoundDetailView: View {
    @Environment(GameStore.self) private var store
    let roundID: UUID

    private var teams: [TeamViewData] { store.round(id: roundID)?.teams ?? [] }
    private var roundIndex: Int { (store.round(id: roundID)?.index ?? 0) + 1 }
    private var selectedTeamID: UUID? { store.round(id: roundID)?.selectedTeamID }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if let round = store.round(id: roundID) {
                        ForEach(round.teams) { team in
                            TeamCircle(team: team, isSelected: selectedTeamID == team.id)
                                .onTapGesture { store.round(id: roundID)?.selectedTeamID = team.id }
                                .contextMenu {
                                    Button(role: .destructive) { store.removeTeam(team.id, from: roundID) } label: {
                                        Label("Remove Team", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }

            if let teamID = selectedTeamID {
                TeamDetailView(roundID: roundID, teamID: teamID)
            } else {
                ContentUnavailableView("Select a team", systemImage: "door.left.hand.closed", description: Text("Tap a circle above."))
            }
        }
        .onAppear { selectFirstIfNeeded() }
        .onChange(of: teams.map(\.id)) {
            if let sel = selectedTeamID, !teams.contains(where: { $0.id == sel }) {
                store.round(id: roundID)?.selectedTeamID = nil
            }
            selectFirstIfNeeded()
        }
    }

    private func selectFirstIfNeeded() {
        if selectedTeamID == nil, let first = teams.first?.id {
            store.round(id: roundID)?.selectedTeamID = first
        }
    }
}

#Preview {
    let game = GameViewData(game: AvalonGame.random())
    let store = GameStore(game: game)
    RoundDetailView(roundID: game.rounds[0].id)
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
