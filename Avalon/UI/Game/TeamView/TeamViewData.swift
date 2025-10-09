import SwiftUI

@Observable
final class TeamViewData: Identifiable {
    let id: UUID
    var index: Int
    var status: TeamVoteStatus = .notStarted
    var result: TeamVoteResult?
    var leader: Player?
    var members: [Player]
    var votesByVoter: [Player: VoteType]

    init(id: UUID = UUID(), index: Int, leader: Player? = nil, members: [Player] = [], votesByVoter: [Player: VoteType] = [:]) {
        self.id = id
        self.index = index
        self.leader = leader
        self.members = members
        self.votesByVoter = votesByVoter
    }

    init(team: TeamVote) {
        id = team.id
        index = team.teamIndex
        status = team.status
        result = team.result
        leader = Player.defaultPlayers.first { $0.id == team.leaderID }
        var memberPlayers: [Player] = []
        for memberID in team.teamMemberIDs {
            memberPlayers.append(Player.defaultPlayers.first { $0.id == memberID } ?? Player.random())
        }
        members = memberPlayers
        votesByVoter = team.votesByVoter
    }
}
