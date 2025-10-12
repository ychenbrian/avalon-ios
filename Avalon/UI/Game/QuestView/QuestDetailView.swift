import SwiftUI

struct QuestDetailView: View {
    @Environment(GameStore.self) private var store
    let questID: UUID

    private var teams: [TeamViewData] { store.quest(id: questID)?.teams ?? [] }
    private var roundIndex: Int { (store.quest(id: questID)?.index ?? 0) + 1 }
    private var selectedTeamID: UUID? { store.quest(id: questID)?.selectedTeamID }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if let quest = store.quest(id: questID) {
                        ForEach(quest.teams) { team in
                            TeamCircle(team: team, isSelected: selectedTeamID == team.id)
                                .onTapGesture { store.quest(id: questID)?.selectedTeamID = team.id }
                                .contextMenu {
                                    Button(role: .destructive) { store.removeTeam(team.id, from: questID) } label: {
                                        Label("Remove Team", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }

            if store.quest(id: questID)?.result?.type != nil {
                ResultView(questID: questID)
            }

            if let teamID = selectedTeamID {
                TeamDetailView(questID: questID, teamID: teamID)
            } else {
                ContentUnavailableView("Select a team", systemImage: "door.left.hand.closed", description: Text("Tap a circle above."))
            }
        }
        .onAppear { selectFirstIfNeeded() }
        .onChange(of: teams.map(\.id)) {
            if let sel = selectedTeamID, !teams.contains(where: { $0.id == sel }) {
                store.quest(id: questID)?.selectedTeamID = nil
            }
            selectFirstIfNeeded()
        }
    }

    private func selectFirstIfNeeded() {
        if selectedTeamID == nil, let first = teams.first?.id {
            store.quest(id: questID)?.selectedTeamID = first
        }
    }
}

#Preview {
    let game = GameViewData(game: AvalonGame.random())
    let store = GameStore(game: game)
    QuestDetailView(questID: game.quests[0].id)
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
