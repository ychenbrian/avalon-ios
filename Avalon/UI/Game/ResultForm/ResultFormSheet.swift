import SwiftUI

struct ResultFormSheet: View {
    let players: [Player]
    let onSave: (_ questID: UUID, _ failCount: Int) -> Void
    let onCancel: () -> Void
    let onClearResult: () -> Void

    @State private var draft: QuestFormDraft

    init(
        questID: UUID,
        teamID: UUID,
        leader: Player?,
        members: [Player],
        players: [Player],
        votesByVoter: [PlayerID: VoteType],
        teamSize: Int,
        requiredFails: Int,
        failCount: Int? = nil,
        onSave: @escaping (_ questID: UUID, _ failCount: Int) -> Void,
        onCancel: @escaping () -> Void,
        onClearResult: @escaping () -> Void
    ) {
        self.players = players
        self.onSave = onSave
        self.onCancel = onCancel
        self.onClearResult = onClearResult

        let initialDraft = QuestFormDraft(
            questID: questID,
            teamID: teamID,
            leader: leader,
            members: Set(members),
            players: players,
            votesByVoter: votesByVoter,
            teamSize: teamSize,
            requiredFails: requiredFails,
            failCount: failCount ?? 0,
            hasFinished: failCount != nil
        )

        _draft = .init(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(alignment: .center, spacing: 8) {
                    Text("resultForm.leader.label")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    if let leader = draft.leader {
                        overlayForPlayer(leader)
                    } else {
                        Text("resultForm.leader.none")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("resultForm.proposedTeam.label")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    let members = draft.members.sorted(by: { $0.index < $1.index })
                    if !members.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(members, id: \.id) { player in
                                overlayForPlayer(player)
                            }
                        }
                    } else {
                        Text("resultForm.proposedTeam.none")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                Text("resultForm.failCount.label")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

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

                if draft.hasFinished {
                    Divider()

                    Button {
                        onClearResult()
                    } label: {
                        Text("resultForm.clearResult.button")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .buttonStyle(.glassProminent)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("resultForm.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Text("resultForm.cancel.button")
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel(String(localized: "resultForm.cancel.accessibility"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(
                            draft.questID,
                            draft.failCount
                        )
                    } label: {
                        Text("resultForm.save.button")
                    }
                    .foregroundStyle(.blue)
                    .accessibilityLabel(String(localized: "resultForm.save.accessibility"))
                }
            }
            .interactiveDismissDisabled(false)
        }
    }

    private func overlayForPlayer(_ player: Player) -> some View {
        let vote = draft.votesByVoter[player.id]
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

struct ResultFormSheetPreview: View {
    var body: some View {
        let players = Player.defaultPlayers()
        ResultFormSheet(
            questID: UUID(),
            teamID: UUID(),
            leader: players[3],
            members: [players[3], players[6]],
            players: players,
            votesByVoter: [:],
            teamSize: 4,
            requiredFails: 2,
            failCount: 1,
            onSave: { _, _ in },
            onCancel: {},
            onClearResult: {}
        )
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ResultFormSheetPreview()
}
