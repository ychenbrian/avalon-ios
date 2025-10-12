import SwiftUI

@Observable
final class GameViewData: Identifiable {
    let id: UUID
    var name: String
    var quests: [QuestViewData]
    var selectedQuestID: UUID?

    init(id: UUID = UUID(), name: String, quests: [QuestViewData] = []) {
        self.id = id
        self.name = name
        self.quests = quests
        selectedQuestID = quests.first?.id
    }

    init(game: AvalonGame) {
        id = game.id
        name = "Game 1"
        quests = game.quests.map(QuestViewData.init(quest:))
        selectedQuestID = quests.first?.id
    }
}
