import SwiftUI

@Observable
final class ResultViewData: Identifiable {
    let id: UUID
    var type: ResultType?
    var failVotes: Int?

    init(id: UUID = UUID(), type: ResultType? = nil, failCount: Int) {
        self.id = id
        self.type = type
        failVotes = failCount
    }

    init(quest: QuestResult?) {
        id = UUID()
        type = quest?.type
        failVotes = quest?.failVotes
    }
}
