import SwiftUI

struct PlayerVoteView: View {
    let team: DBModel.Team
    let player: Player

    // MARK: - Derived

    private var teamLabel: String {
        "T\(team.teamIndex + 1)"
    }

    private var members: [Player] {
        team.sortedMembers
    }

    private var isApproved: Bool? {
        guard let vote = team.votesByVoter[player.id] else { return nil }
        return vote == .approve
    }

    private var voteText: String {
        switch isApproved {
        case true: return "✓"
        case false: return "✕"
        case nil: return "·"
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            Text(teamLabel)
                .font(.caption.bold())
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(team.result?.isApproved == true ? Color.appColor(.selectedColor) : Color.appColor(.selectedColor).opacity(0.3))
                )
                .foregroundColor(.appColor(.primaryTextColor))

            Rectangle()
                .frame(width: 1, height: 16)
                .foregroundStyle(.secondary.opacity(0.4))

            if let leader = team.leader {
                Text("\(leader.index + 1)")
                    .font(.caption2)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(leader.id == player.id ? Color.appColor(.highlightColor) : Color.appColor(.emptyColor))
                    )
            } else {
                Text("–")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Rectangle()
                .frame(width: 1, height: 16)
                .foregroundStyle(.secondary.opacity(0.4))

            if members.isEmpty {
                Text("–")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                HStack(spacing: 4) {
                    ForEach(members, id: \.id) { member in
                        Text("\(member.index + 1)")
                            .font(.caption2)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle().fill(member.id == player.id ? Color.appColor(.highlightColor) : Color.appColor(.emptyColor))
                            )
                    }
                }
            }

            Rectangle()
                .frame(width: 1, height: 16)
                .foregroundStyle(.secondary.opacity(0.4))

            if let isApproved {
                Text(voteText)
                    .font(.caption.bold())
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(isApproved ? Color.appColor(.successColor) : Color.appColor(.failColor))
                    )
                    .foregroundColor(Color.appColor(.primaryTextColor))
            } else {
                Text("–")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PlayerVoteView(
            team: .random(roundIndex: 1, teamIndex: 0),
            player: Player.defaultPlayers().first!
        )
        PlayerVoteView(
            team: .random(roundIndex: 1, teamIndex: 1),
            player: Player.defaultPlayers().last!
        )
    }
    .padding()
}
