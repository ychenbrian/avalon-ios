import Foundation
import SwiftUI

public typealias PlayerID = UUID
public typealias TeamID = UUID

public enum VoteType: String, Codable, CaseIterable, Equatable {
    case approve
    case reject
}

// MARK: - Status & Result

enum TeamStatus: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished
}

struct TeamResult: Codable, Equatable {
    let isApproved: Bool
    let approvedCount: Int
    let rejectedCount: Int
    let decidedAt: Date

    init(isApproved: Bool, approvedCount: Int, rejectedCount: Int, decidedAt: Date = Date()) {
        self.isApproved = isApproved
        self.approvedCount = approvedCount
        self.rejectedCount = rejectedCount
        self.decidedAt = decidedAt
    }

    var displayText: String {
        switch isApproved {
        case true: return String(localized: "team.result.approve")
        case false: return String(localized: "team.result.reject")
        }
    }

    var color: Color {
        switch isApproved {
        case true: return .green
        case false: return .red
        }
    }
}

// MARK: - Team

struct Team: Identifiable, Codable, Equatable {
    let id: TeamID
    let roundIndex: Int
    let teamIndex: Int

    var status: TeamStatus

    var leaderID: PlayerID?
    var memberIDs: [PlayerID]
    var votesByVoter: [Player: VoteType]

    var result: TeamResult?

    init(
        id: TeamID = TeamID(),
        roundIndex: Int,
        teamIndex: Int,
        status: TeamStatus = .notStarted,
        leaderID: PlayerID? = nil,
        teamMemberIDs: [PlayerID] = [],
        votesByVoter: [Player: VoteType] = [:],
        result: TeamResult? = nil
    ) {
        self.id = id
        self.roundIndex = roundIndex
        self.teamIndex = teamIndex
        self.status = status
        self.leaderID = leaderID
        memberIDs = teamMemberIDs
        self.votesByVoter = votesByVoter
        self.result = result
    }
}

// MARK: - Derived Properties & State Machine Helpers

extension Team {
    var approvedVoters: Set<Player> {
        Set(votesByVoter.compactMap { $0.value == .approve ? $0.key : nil })
    }

    var rejectedVoters: Set<Player> {
        Set(votesByVoter.compactMap { $0.value == .reject ? $0.key : nil })
    }

    var approvedCount: Int { approvedVoters.count }
    var rejectedCount: Int { rejectedVoters.count }

    var isApprovedByVotes: Bool { approvedCount > rejectedCount }

    var isFinished: Bool { status == .finished }
}
