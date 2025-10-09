import Foundation
import SwiftUI

public typealias PlayerID = UUID
public typealias TeamVoteID = UUID

public enum VoteType: String, Codable, CaseIterable, Equatable {
    case approve
    case reject
}

// MARK: - Status & Result

enum TeamVoteStatus: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished
}

struct TeamVoteResult: Codable, Equatable {
    let isApproved: Bool
    let approvedCount: Int
    let rejectedCount: Int
    /// Snapshot for audit/debug; truth still lives in `votes`
    let decidedAt: Date

    init(isApproved: Bool, approvedCount: Int, rejectedCount: Int, decidedAt: Date = Date()) {
        self.isApproved = isApproved
        self.approvedCount = approvedCount
        self.rejectedCount = rejectedCount
        self.decidedAt = decidedAt
    }

    var displayText: String {
        switch isApproved {
        case true: return "Approve"
        case false: return "Reject"
        }
    }

    var color: Color {
        switch isApproved {
        case true: return .green
        case false: return .red
        }
    }
}

// MARK: - TeamVote

struct TeamVote: Identifiable, Codable, Equatable {
    let id: TeamVoteID
    let roundIndex: Int
    let teamIndex: Int

    var status: TeamVoteStatus

    var leaderID: PlayerID?
    /// Proposed team members (player IDs). The leader may or may not be in the team depending on rules.
    var teamMemberIDs: [PlayerID]

    /// Map to prevent duplicate votes; last vote wins if you allow changes while voting.
    var votesByVoter: [Player: VoteType]

    /// Final result; non-nil only when `status == .finished`
    var result: TeamVoteResult?

    init(
        id: TeamVoteID = TeamVoteID(),
        roundIndex: Int,
        teamIndex: Int,
        status: TeamVoteStatus = .notStarted,
        leaderID: PlayerID? = nil,
        teamMemberIDs: [PlayerID] = [],
        votesByVoter: [Player: VoteType] = [:],
        result: TeamVoteResult? = nil
    ) {
        self.id = id
        self.roundIndex = roundIndex
        self.teamIndex = teamIndex
        self.status = status
        self.leaderID = leaderID
        self.teamMemberIDs = teamMemberIDs
        self.votesByVoter = votesByVoter
        self.result = result
    }
}

// MARK: - Derived Properties & State Machine Helpers

extension TeamVote {
    var approvedVoters: Set<Player> {
        Set(votesByVoter.compactMap { $0.value == .approve ? $0.key : nil })
    }

    var rejectedVoters: Set<Player> {
        Set(votesByVoter.compactMap { $0.value == .reject ? $0.key : nil })
    }

    var approvedCount: Int { approvedVoters.count }
    var rejectedCount: Int { rejectedVoters.count }

    /// Tie-break rule defined here: strictly more approvals than rejections passes.
    var isApprovedByVotes: Bool { approvedCount > rejectedCount }

    var isFinished: Bool { status == .finished }
}
