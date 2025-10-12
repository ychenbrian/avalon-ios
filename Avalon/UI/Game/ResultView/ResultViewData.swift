import SwiftUI

@Observable
final class ResultViewData: Identifiable {
    let id: UUID
    var type: ResultType?
    var failCount: Int?

    init(id: UUID = UUID(), type: ResultType? = nil, failCount: Int) {
        self.id = id
        self.type = type
        self.failCount = failCount
    }

    init(quest: QuestResult?) {
        id = UUID()
        type = quest?.type
        failCount = quest?.failCount
    }
}
