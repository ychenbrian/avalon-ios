import SwiftUI

struct TeamDetailView: View {
    @Environment(GameStore.self) private var store
    let questID: UUID
    let teamID: UUID

    @State private var isEditingTeam = false
    @State private var isEditingResult = false
    @State private var activeAlert: TeamDetailAlert?

    private var team: TeamViewData? { store.team(id: teamID, in: questID) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                if let members = team?.members.sorted(by: { $0.index < $1.index }), !members.isEmpty {
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
            HStack {
                Button("Edit Team") {
                    if let quest = store.quest(id: questID) {
                        if quest.status != .finished {
                            isEditingTeam = true
                        } else {
                            activeAlert = .cannotEditTeam
                        }
                    }
                }
                .font(.headline)
                .foregroundColor(.primary)
                .buttonStyle(.glass)

                Button("Edit Result") {
                    isEditingResult = true
                }
                .font(.headline)
                .foregroundColor(.primary)
                .buttonStyle(.glass)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        .alert(item: $activeAlert) { route in
            switch route {
            case .cannotEditTeam:
                return Alert(
                    title: Text("Cannot edit this team"),
                    message: Text("The quest has finished, you cannot edit any teams of this quest."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .sheet(isPresented: $isEditingTeam) {
            if let quest = store.quest(id: questID), let team = store.team(id: teamID, in: questID) {
                TeamFormSheet(
                    questID: questID,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: store.players,
                    votesByVoter: team.votesByVoter,
                    requiredTeamSize: quest.requiredTeamSize,
                    showVotes: true,
                    onSave: { questID, teamID, leader, members, votesByVoter in
                        store.updateTeam(questID: questID, teamID: teamID, leader: leader, members: members, votesByVoter: votesByVoter)
                        store.finishTeam(questID: questID, teamID: teamID)
                        withAnimation {
                            isEditingTeam = false
                            if store.team(id: teamID, in: questID)?.result?.isApproved == true {
                                isEditingResult = true
                            } else {
                                let teamIndex = store.team(id: teamID, in: questID)?.index ?? 0
                                if teamIndex + 1 < GameRules.teamsPerQuest, let nextTeam = store.quest(id: questID)?.teams[teamIndex + 1] {
                                    store.startTeam(questID: questID, teamID: nextTeam.id)
                                }
                            }
                        }
                    },
                    onCancel: { withAnimation { isEditingTeam = false } }
                )
                .presentationDetents([.large])
            } else {
                Color.clear.onAppear { isEditingTeam = false }
            }
        }
        .sheet(isPresented: $isEditingResult) {
            if let quest = store.quest(id: questID), let team = store.team(id: teamID, in: questID) {
                ResultFormSheet(
                    questID: questID,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: store.players,
                    votesByVoter: team.votesByVoter,
                    teamSize: quest.requiredTeamSize,
                    requiredFails: quest.requiredFails,
                    failCount: quest.result?.failCount,
                    onSave: { questID, failCount in
                        store.updateQuestResult(questID: questID, failCount: failCount)
                        withAnimation { isEditingResult = false }
                    },
                    onCancel: { withAnimation { isEditingResult = false } },
                    onClearResult: { withAnimation {
                        isEditingResult = false
                        store.clearQuestResult(questID: questID)
                    } }
                )
                .presentationDetents([.medium])
            } else {
                Color.clear.onAppear { isEditingResult = false }
            }
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
}

#Preview {
    let game = GameViewData(game: AvalonGame.random())
    let quest = game.quests[0]
    let store = GameStore(game: game)
    TeamDetailView(questID: quest.id, teamID: quest.teams.first?.id ?? UUID())
        .environment(store)
        .padding()
        .frame(maxWidth: 600)
}
