import SwiftUI

struct TeamFormSheet: View {
    let players: [Player]
    var showVotes: Bool
    let onSave: (_ questID: UUID, _ teamID: UUID, _ leader: Player?, _ members: [Player], _ votesByVoter: [Player: VoteType]) -> Void
    let onCancel: () -> Void

    @State private var draft: TeamFormDraft

    private func toggleApprove(_ player: Player) {
        if draft.votesByVoter[player] == .approve {
            draft.castVote(voter: player, vote: .reject)
        } else {
            draft.castVote(voter: player, vote: .approve)
        }
    }

    private func toggleReject(_ player: Player) {
        if draft.votesByVoter[player] == .reject {
            draft.castVote(voter: player, vote: .approve)
        } else {
            draft.castVote(voter: player, vote: .reject)
        }
    }

    init(
        questID: UUID,
        teamID: UUID,
        leader: Player?,
        members: [Player],
        players: [Player],
        votesByVoter: [Player: VoteType],
        requiredTeamSize: Int,
        showVotes: Bool = false,
        onSave: @escaping (_ questID: UUID, _ teamID: UUID, _ leader: Player?, _ members: [Player], _ votesByVoter: [Player: VoteType]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.players = players
        self.showVotes = showVotes
        self.onSave = onSave
        self.onCancel = onCancel

        var initialDraft = TeamFormDraft(
            questID: questID,
            teamID: teamID,
            leader: leader,
            members: Set(members),
            players: players,
            requiredTeamSize: requiredTeamSize,
            votesByVoter: votesByVoter
        )
        if showVotes {
            initialDraft.initialVotes()
        }

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Leader
                Text("teamForm.leader.label")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.top, 12)

                PlayerGrid(
                    players: self.players,
                    selected: { draft.leader == $0 },
                    action: { player in
                        draft.leader = player
                    }
                )
                .padding(.vertical, 12)

                // Team
                let teamCount = draft.members.count
                let teamSize = draft.requiredTeamSize
                Text(String(format: NSLocalizedString("teamForm.team.label", comment: ""), teamCount, teamSize))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.top, 8)

                PlayerGrid(
                    players: self.players,
                    selected: { draft.members.contains($0) },
                    action: { draft.toggleTeamMember($0) }
                )
                .padding(.vertical, 12)

                if showVotes {
                    Divider()

                    // Approvals
                    Text("teamForm.approvals.label")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.top, 12)

                    PlayerGrid(
                        players: self.players,
                        selectedColor: .green,
                        selected: { draft.votesByVoter[$0] == .approve },
                        action: { toggleApprove($0) }
                    )
                    .padding(.vertical, 12)

                    // Rejects
                    Text("teamForm.rejects.label")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.top, 8)

                    PlayerGrid(
                        players: self.players,
                        selectedColor: .red,
                        selected: { draft.votesByVoter[$0] == .reject },
                        action: { toggleReject($0) }
                    )
                    .padding(.vertical, 12)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("teamForm.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Text("teamForm.cancel.button")
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel(String(localized: "teamForm.cancel.accessibility"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(
                            draft.questID,
                            draft.teamID,
                            draft.leader,
                            Array(draft.members),
                            draft.votesByVoter
                        )
                    } label: {
                        Text("teamForm.save.button")
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel(String(localized: "teamForm.save.accessibility"))
                }
            }
            .interactiveDismissDisabled(false)
        }
    }
}

struct TeamFormSheetPreview: View {
    var body: some View {
        TeamFormSheet(
            questID: UUID(),
            teamID: UUID(),
            leader: nil,
            members: [],
            players: Player.defaultPlayers,
            votesByVoter: [:],
            requiredTeamSize: 4,
            onSave: { _, _, _, _, _ in },
            onCancel: {}
        )
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    TeamFormSheetPreview()
}
