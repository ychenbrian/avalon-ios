import SwiftUI

struct QuestFormSheet: View {
    let players: [Player]
    let onSave: (_ roundID: UUID, _ teamID: UUID, _ failCount: Int) -> Void
    let onCancel: () -> Void

    @State private var draft: QuestFormDraft

    init(
        roundID: UUID,
        teamID: UUID,
        leader: Player?,
        members: [Player],
        players: [Player],
        votesByVoter: [Player: VoteType],
        teamSize: Int,
        requiredFails: Int,
        showVotes _: Bool = false,
        onSave: @escaping (_ roundID: UUID, _ teamID: UUID, _ failCount: Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.players = players
        self.onSave = onSave
        self.onCancel = onCancel

        let initialDraft = QuestFormDraft(
            roundID: roundID,
            teamID: teamID,
            leader: leader,
            members: Set(members),
            players: players,
            votesByVoter: votesByVoter,
            teamSize: teamSize,
            requiredFails: requiredFails
        )

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Leader:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let leader = draft.leader {
                        overlayForPlayer(leader)
                    } else {
                        Text("No leader yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposed Team")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    let members = draft.members.sorted(by: { $0.index < $1.index })
                    if !members.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(members, id: \.id) { player in
                                overlayForPlayer(player)
                            }
                        }
                    } else {
                        Text("No members yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Number of Fails")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                CountRadioGroup(
                    teamSize: draft.teamSize,
                    requiredFails: draft.requiredFails,
                    selected: { count in
                        count == draft.failCount
                    },
                    action: { count in
                        draft.failCount = count
                    }
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("Select Request Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel("Cancel editing quest result")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            draft.roundID,
                            draft.teamID,
                            draft.failCount
                        )
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel("Save quest result")
                }
            }
            .interactiveDismissDisabled(false)
        }
    }

    private func overlayForPlayer(_ player: Player) -> some View {
        let vote = draft.votesByVoter[player]
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
}

struct QuestFormSheetPreview: View {
    var body: some View {
        QuestFormSheet(
            roundID: UUID(),
            teamID: UUID(),
            leader: Player.defaultPlayers[3],
            members: [Player.defaultPlayers[3], Player.defaultPlayers[6]],
            players: Player.defaultPlayers,
            votesByVoter: [:],
            teamSize: 4,
            requiredFails: 2,
            onSave: { _, _, _ in },
            onCancel: {}
        )
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    QuestFormSheetPreview()
}
