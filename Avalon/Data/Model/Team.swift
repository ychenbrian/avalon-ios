import Foundation
import SwiftData
import SwiftUI

public typealias TeamID = UUID

// MARK: - DBModel

extension DBModel {
    @Model
    final class Team {
        var id: TeamID
        var roundIndex: Int
        var teamIndex: Int
        var status: TeamStatus
        var leader: Player?
        var members: [Player]
        var votesByVoter: [PlayerID: VoteType]
        var result: TeamResult?

        init(
            id: TeamID = TeamID(),
            roundIndex: Int,
            teamIndex: Int,
            status: TeamStatus = .notStarted,
            leader: Player? = nil,
            members: [Player] = [],
            votesByVoter: [PlayerID: VoteType] = [:],
            result: TeamResult? = nil
        ) {
            self.id = id
            self.roundIndex = roundIndex
            self.teamIndex = teamIndex
            self.status = status
            self.leader = leader
            self.members = members
            self.votesByVoter = votesByVoter
            self.result = result
        }

        var sortedMembers: [Player] {
            members.sorted { $0.index < $1.index }
        }
    }
}
