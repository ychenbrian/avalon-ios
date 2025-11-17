import SwiftUI

struct PlayerQuestView: View {
    let quest: DBModel.Quest
    let player: Player

    // MARK: - Derived state

    private var approvedTeam: DBModel.Team? {
        quest.approvedTeam
    }

    private var isLeaderOnApprovedTeam: Bool {
        approvedTeam?.leader?.id == player.id
    }

    private var isOnApprovedTeam: Bool {
        approvedTeam?.members.contains { $0.id == player.id } ?? false
    }

    private var questTitle: String {
        String(
            format: NSLocalizedString(
                "playerView.quest.title.format",
                comment: "Quest title text"
            ),
            quest.index + 1
        )
    }

    private var visibleTeams: [DBModel.Team] {
        quest.sortedTeams.filter { $0.status != .notStarted }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView(approvedTeam: approvedTeam, result: quest.result?.type)

            if !visibleTeams.isEmpty {
                Divider()

                HStack(spacing: 8) {
                    Text("playerView.quest.title.team")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Rectangle()
                        .frame(width: 1, height: 12)
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("playerView.quest.title.leader")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Rectangle()
                        .frame(width: 1, height: 12)
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("playerView.quest.title.members")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Rectangle()
                        .frame(width: 1, height: 12)
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("playerView.quest.title.vote")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }

                ForEach(visibleTeams, id: \.id) { team in
                    PlayerVoteView(team: team, player: player)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerView(approvedTeam _: DBModel.Team?, result: ResultType?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(questTitle)
                    .font(.headline)
                    .fontWeight(.bold)

                if approvedTeam != nil {
                    if let result {
                        Text("\(result.displayText)")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(result.color)
                            )
                            .foregroundColor(.appColor(.primaryTextColor))
                    }

                    Spacer()

                    statusPill(
                        text: isLeaderOnApprovedTeam ? String(localized: "playerView.quest.leader") : String(localized: "playerView.quest.notLeader"),
                        isHighlighted: isLeaderOnApprovedTeam
                    )

                    statusPill(
                        text: isOnApprovedTeam ? String(localized: "playerView.quest.onTeam") : String(localized: "playerView.quest.notOnTeam"),
                        isHighlighted: isOnApprovedTeam
                    )
                } else {
                    Text("playerView.quest.noTeamYet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
    }

    private func statusPill(text: String, isHighlighted: Bool) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isHighlighted
                        ? Color.appColor(.successColor)
                        : Color.appColor(.emptyColor))
            )
            .foregroundColor(isHighlighted ? .appColor(.primaryTextColor) : .appColor(.disabledTextColor))
    }
}

#Preview {
    VStack {
        PlayerQuestView(
            quest: .random(index: 1),
            player: Player.defaultPlayers().first!
        )
        .padding()
    }
}
