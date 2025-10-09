import Foundation

struct TeamFormDraft: Equatable {
    var roundID: UUID
    var teamID: UUID
    var leader: Player?
    var members: Set<Player>
    var requiredTeamSize: Int
    var showVotes: Bool = false
    var votesByVoter: [Player: VoteType] = [:]

    mutating func setLeader(_ player: Player?) {
        leader = player
    }

    mutating func toggleTeamMember(_ member: Player) {
        if members.contains(member) {
            members.remove(member)
        } else if members.count < requiredTeamSize {
            members.insert(member)
        }
    }

    mutating func castVote(voter: Player, vote: VoteType) {
        votesByVoter[voter] = vote
    }

    var isValid: Bool {
        members.count == requiredTeamSize
    }

    var countText: String {
        "(\(members.count)/\(requiredTeamSize))"
    }
}
