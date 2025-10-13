import SwiftUI

struct QuestFormDraft: Equatable {
    var questID: UUID
    var teamID: UUID
    var leader: Player?
    var members: Set<Player>
    var players: [Player]
    var votesByVoter: [Player: VoteType]
    var teamSize: Int
    var requiredFails: Int
    var failCount: Int
    var hasFinished: Bool = false

    mutating func setFailCount(_ count: Int) {
        failCount = count
    }
}
