import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject var presenter: GamePresenter
    let questID: UUID

    private var teams: [DBModel.Team] { presenter.quest(id: questID)?.sortedTeams ?? [] }
    private var roundIndex: Int { (presenter.quest(id: questID)?.index ?? 0) + 1 }
    private var selectedTeamID: UUID? { presenter.quest(id: questID)?.selectedTeamID }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if presenter.quest(id: questID)?.result?.type != nil {
                ResultView(questID: questID)
            }

            Text("questDetailView.voteTrack.title")
                .padding(.top, 8)
                .font(.headline)
                .foregroundColor(.appColor(.primaryTextColor))

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if let quest = presenter.quest(id: questID) {
                        ForEach(quest.sortedTeams) { team in
                            TeamCircle(team: team, isSelected: selectedTeamID == team.id)
                                .onTapGesture { presenter.quest(id: questID)?.selectedTeamID = team.id }
                        }
                    }
                }
            }

            if let teamID = selectedTeamID {
                TeamDetailView(questID: questID, teamID: teamID)
            } else {
                ContentUnavailableView("questDetailView.unavailable.title", systemImage: "door.left.hand.closed", description: Text("questDetailView.unavailable.description"))
            }
        }
        .onAppear { selectFirstIfNeeded() }
        .onChange(of: teams.map(\.id)) {
            if let selected = selectedTeamID, !teams.contains(where: { $0.id == selected }) {
                presenter.quest(id: questID)?.selectedTeamID = nil
            }
            selectFirstIfNeeded()
        }
    }

    private func selectFirstIfNeeded() {
        if selectedTeamID == nil, let first = teams.first?.id {
            presenter.quest(id: questID)?.selectedTeamID = first
        }
    }
}

#Preview {
    let presenter = GamePresenter.preview()
    let questID = presenter.game.sortedQuests.first?.id ?? UUID()
    return QuestDetailView(questID: questID)
        .environmentObject(presenter)
        .frame(maxWidth: 600)
        .padding()
}
