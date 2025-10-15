import SwiftUI

@Observable
final class TeamViewData: Identifiable {
    let id: UUID
    var roundIndex: Int
    var teamIndex: Int
    var status: TeamStatus = .notStarted
    var result: TeamResult?
    var leader: Player?
    var members: [Player]
    var votesByVoter: [Player: VoteType]

    init(id: UUID = UUID(), roundIndex: Int, teamIndex: Int, leader: Player? = nil, members: [Player] = [], votesByVoter: [Player: VoteType] = [:]) {
        self.id = id
        self.roundIndex = roundIndex
        self.teamIndex = teamIndex
        self.leader = leader
        self.members = members
        self.votesByVoter = votesByVoter
    }

    init(team: Team) {
        id = team.id
        roundIndex = team.roundIndex
        teamIndex = team.teamIndex
        status = team.status
        result = team.result
        leader = Player.defaultPlayers().first { $0.id == team.leaderID }
        var memberPlayers: [Player] = []
        for memberID in team.memberIDs {
            memberPlayers.append(Player.defaultPlayers().first { $0.id == memberID } ?? Player.random())
        }
        members = memberPlayers
        votesByVoter = team.votesByVoter
    }

    func toTeam() -> Team {
        .init(
            id: id,
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: status,
            leaderID: leader?.id ?? UUID(),
            memberIDs: members.map(\.id),
            votesByVoter: votesByVoter,
            result: result
        )
    }
}
