import SwiftData
import SwiftUI

@Observable
final class GameViewData: Identifiable {
    let id: UUID
    var name: String
    var startedAt: String?
    var finishedAt: String?
    var players: [Player]
    var status: GameStatus
    var result: GameResult?
    var quests: [QuestViewData]
    var selectedQuestID: UUID?
    var persistentModelID: PersistentIdentifier?

    init(id: UUID = UUID(), name: String = generateReference(), players: [Player], status: GameStatus = .inProgress, result: GameResult? = nil, quests: [QuestViewData] = []) {
        self.id = id
        self.players = players
        self.name = name
        self.status = status
        self.result = result
        let sortedQuests = quests.sorted { $0.index < $1.index }
        self.quests = sortedQuests
        selectedQuestID = sortedQuests.last(where: { $0.status != .notStarted })?.id
        persistentModelID = nil
    }

    init(game: AvalonGame) {
        id = game.id
        name = game.name
        startedAt = game.startedAt
        finishedAt = game.finishedAt
        players = game.players
        status = game.status
        result = game.result
        let sortedQuests = game.quests.sorted { $0.index < $1.index }
        quests = sortedQuests.map { QuestViewData(quest: $0, players: game.players) }
        selectedQuestID = sortedQuests.last(where: { $0.status != .notStarted })?.id
        persistentModelID = game.persistentModelID
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
