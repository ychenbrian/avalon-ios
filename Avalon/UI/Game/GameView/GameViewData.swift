import SwiftUI

@Observable
final class GameViewData: Identifiable {
    let id: UUID
    var name: String?
    var startedAt: String?
    var finishedAt: String?
    var players: [Player]
    var status: GameStatus
    var result: GameResult?
    var quests: [QuestViewData]
    var selectedQuestID: UUID?

    init(id: UUID = UUID(), name: String?, players: [Player], status: GameStatus = .inProgress, result: GameResult? = nil, quests: [QuestViewData] = []) {
        self.id = id
        self.players = players
        self.name = name
        self.status = status
        self.result = result
        self.quests = quests
        selectedQuestID = quests.first?.id
    }

    init(game: AvalonGame) {
        id = game.id
        name = game.name
        startedAt = game.startedAt
        finishedAt = game.finishedAt
        players = game.players
        status = game.status
        result = game.result
        quests = game.quests.map(QuestViewData.init(quest:))
        selectedQuestID = quests.first?.id
    }

    func toAvalonGame() -> AvalonGame {
        AvalonGame(
            id: id,
            name: name,
            startedAt: startedAt,
            finishedAt: finishedAt,
            players: players,
            quests: quests.map { $0.toQuest() },
            status: status,
            result: result
        )
    }
}
