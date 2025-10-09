import SwiftUI

@Observable
class QuestExecutionEditState {
    var leader: Player?
    var team: Set<Player>
    var failVotes: Int

    init(from quest: GameQuest) {
        leader = quest.leader
        team = Set(quest.team)
        failVotes = quest.failVotes
    }

    func apply(to quest: inout GameQuest) {
        quest.team = Array(team)
        quest.leader = leader
        quest.failVotes = failVotes
    }
}
