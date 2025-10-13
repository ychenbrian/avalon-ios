import SwiftUI

@Observable
final class GameViewData: Identifiable {
    let id: UUID
    var name: String
    var status: GameStatus
    var result: GameResult?
    var quests: [QuestViewData]
    var selectedQuestID: UUID?

    init(id: UUID = UUID(), name: String, status: GameStatus = .inProgress, result: GameResult? = nil, quests: [QuestViewData] = []) {
        self.id = id
        self.name = name
        self.status = status
        self.result = result
        self.quests = quests
        selectedQuestID = quests.first?.id
    }

    init(game: AvalonGame) {
        id = game.id
        name = "Game 1"
        status = game.status
        result = game.result
        quests = game.quests.map(QuestViewData.init(quest:))
        selectedQuestID = quests.first?.id
    }
}
