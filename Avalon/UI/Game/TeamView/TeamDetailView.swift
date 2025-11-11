import SwiftUI

struct TeamDetailView: View {
    @EnvironmentObject var presenter: GamePresenter
    let questID: UUID
    let teamID: UUID

    @State private var isEditingTeam = false
    @State private var isEditingResult = false
    @State private var isGameFinish = false
    @State private var activeAlert: TeamDetailAlert?

    private var team: DBModel.Team? { presenter.team(id: teamID, in: questID) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("teamDetail.leader.label")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let leader = team?.leader {
                    overlayForPlayer(leader)
                } else {
                    Text("teamDetail.leader.none")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("teamDetail.proposedTeam.label")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let members = team?.sortedMembers, !members.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(members, id: \.id) { player in
                            overlayForPlayer(player)
                        }
                    }
                } else {
                    Text("teamDetail.proposedTeam.none")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("teamDetail.votes.label")
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
                Button {
                    if let quest = presenter.quest(id: questID) {
                        if quest.status != .finished {
                            isEditingTeam = true
                        } else {
                            activeAlert = .cannotEditTeam
                        }
                    }
                } label: {
                    Text("teamDetail.editTeam.button")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .buttonStyle(.glass)

                Button {
                    isEditingResult = true
                } label: {
                    Text("teamDetail.editResult.button")
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
                    title: Text("teamDetail.cannotEditTeam.title"),
                    message: Text("teamDetail.cannotEditTeam.message"),
                    dismissButton: .default(Text("teamDetail.cannotEditTeam.ok"))
                )
            }
        }
        .sheet(isPresented: $isEditingTeam) {
            if let quest = presenter.quest(id: questID), let team = presenter.team(id: teamID, in: questID) {
                TeamFormSheet(
                    questID: questID,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: presenter.players,
                    votesByVoter: team.votesByVoter,
                    requiredTeamSize: quest.requiredTeamSize,
                    showVotes: true,
                    onSave: { questID, teamID, leader, members, votesByVoter in
                        Task { @MainActor in
                            await presenter.updateTeam(
                                questID: questID,
                                teamID: teamID,
                                leader: leader,
                                members: members,
                                votesByVoter: votesByVoter
                            )
                            await presenter.finishTeam(questID: questID, teamID: teamID)

                            let team = presenter.team(id: teamID, in: questID)
                            let isApproved = team?.result?.isApproved == true

                            let nextTeamID: UUID? = {
                                guard !isApproved else { return nil }
                                let idx = team?.teamIndex ?? 0
                                guard idx + 1 < GameRules.teamsPerQuest,
                                      let next = presenter.quest(id: questID)?.sortedTeams[idx + 1] else { return nil }
                                return next.id
                            }()

                            withAnimation {
                                isEditingTeam = false
                                if isApproved {
                                    isEditingResult = true
                                }
                            }

                            if let nextTeamID {
                                await presenter.startTeam(questID: questID, teamID: nextTeamID)
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
            if let quest = presenter.quest(id: questID), let team = presenter.team(id: teamID, in: questID) {
                ResultFormSheet(
                    questID: questID,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: presenter.players,
                    votesByVoter: team.votesByVoter,
                    teamSize: quest.requiredTeamSize,
                    requiredFails: quest.requiredFails,
                    failCount: quest.result?.failCount,
                    onSave: { questID, failCount in
                        Task { @MainActor in
                            let gameFinish = await presenter.updateQuestResult(questID: questID, failCount: failCount)
                            withAnimation {
                                isEditingResult = false
                                if gameFinish {
                                    isGameFinish = true
                                }
                            }
                        }
                    },
                    onCancel: { withAnimation { isEditingResult = false } },
                    onClearResult: {
                        isEditingResult = false
                        Task {
                            await presenter.clearQuestResult(questID: questID)
                        }
                    }
                )
                .presentationDetents([.medium])
            } else {
                Color.clear.onAppear { isEditingResult = false }
            }
        }
        .sheet(isPresented: $isGameFinish) {
            GameFinishFormSheet(
                status: presenter.game.status,
                result: nil,
                onFinish: { _ in
                    withAnimation {
                        isGameFinish = false
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func overlayForPlayer(_ player: Player) -> some View {
        let vote = team?.votesByVoter[player.id]
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
        let players = presenter.players.sorted { $0.index < $1.index }
        let total = players.count
        guard total > 0 else { return [] }

        let firstRowCount = Int(ceil(Double(total) / 2.0))
        let firstRow = Array(players.prefix(firstRowCount))
        let secondRow = Array(players.suffix(total - firstRowCount))

        return [firstRow, secondRow]
    }
}

#Preview {
    let container = DIContainer.preview
    let presenter = GamePresenter.preview()
    let quest = presenter.game.quests[0]
    TeamDetailView(questID: quest.id, teamID: quest.teams.first?.id ?? UUID())
        .environmentObject(presenter)
        .padding()
        .frame(maxWidth: 600)
}
