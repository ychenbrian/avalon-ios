import Foundation
import SwiftData
import SwiftUI

public typealias PlayerID = UUID
public typealias TeamID = UUID

@Model
final class Team {
    var id: TeamID
    var roundIndex: Int
    var teamIndex: Int
    var status: TeamStatus
    var leaderID: PlayerID?
    var memberIDs: [PlayerID]
    var votesByVoter: [PlayerID: VoteType]
    var result: TeamResult?

    init(
        id: TeamID = TeamID(),
        roundIndex: Int,
        teamIndex: Int,
        status: TeamStatus = .notStarted,
        leaderID: PlayerID? = nil,
        memberIDs: [PlayerID] = [],
        votesByVoter: [PlayerID: VoteType] = [:],
        result: TeamResult? = nil
    ) {
        self.id = id
        self.roundIndex = roundIndex
        self.teamIndex = teamIndex
        self.status = status
        self.leaderID = leaderID
        self.memberIDs = memberIDs
        self.votesByVoter = votesByVoter
        self.result = result
    }

    var approvedVoters: Set<PlayerID> {
        Set(votesByVoter.compactMap { $0.value == .approve ? $0.key : nil })
    }

    var rejectedVoters: Set<PlayerID> {
        Set(votesByVoter.compactMap { $0.value == .reject ? $0.key : nil })
    }

    var approvedCount: Int { approvedVoters.count }
    var rejectedCount: Int { rejectedVoters.count }
    var isApprovedByVotes: Bool { approvedCount > rejectedCount }
    var isFinished: Bool { status == .finished }
}
