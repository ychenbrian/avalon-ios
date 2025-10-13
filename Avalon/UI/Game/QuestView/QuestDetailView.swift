import SwiftUI

struct QuestDetailView: View {
    @Environment(GameStore.self) private var store
    let questID: UUID

    private var teams: [TeamViewData] { store.quest(id: questID)?.teams ?? [] }
    private var roundIndex: Int { (store.quest(id: questID)?.index ?? 0) + 1 }
    private var selectedTeamID: UUID? { store.quest(id: questID)?.selectedTeamID }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("questDetailView.voteTrack.title")
                .padding(.top, 8)
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if let quest = store.quest(id: questID) {
                        ForEach(quest.teams) { team in
                            TeamCircle(team: team, isSelected: selectedTeamID == team.id)
                                .onTapGesture { store.quest(id: questID)?.selectedTeamID = team.id }
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
                ContentUnavailableView("questDetailView.unavailable.title", systemImage: "door.left.hand.closed", description: Text("questDetailView.unavailable.description"))
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
