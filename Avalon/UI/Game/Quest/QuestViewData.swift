import SwiftUI

@Observable
final class QuestViewData: Identifiable {
    let id: UUID
    var result: QuestResult?
    var failVotes: Int?

    init(id: UUID = UUID(), result: QuestResult? = nil, failCount: Int) {
        self.id = id
        self.result = result
        failVotes = failCount
    }

    init(quest: GameQuest?) {
        id = UUID()
        result = quest?.result
        failVotes = quest?.failVotes
    }
}
