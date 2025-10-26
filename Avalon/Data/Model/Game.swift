import Foundation
import SwiftData
import SwiftUI

// MARK: - DBModel

extension DBModel {
    @Model
    final class Game: Sendable {
        @Attribute(.unique) var id: UUID
        var name: String
        var startedAt: String?
        var finishedAt: String?
        var players: [Player]
        var quests: [Quest]
        var status: GameStatus
        var result: GameResult?
        var selectedQuestID: UUID?

        init(
            id: UUID = UUID(),
            name: String = generateReference(),
            startedAt: String? = nil,
            finishedAt: String? = nil,
            players: [Player] = [],
            quests: [Quest] = [],
            status: GameStatus = .initial,
            result: GameResult? = nil,
            selectedQuestID: UUID? = nil
        ) {
            self.id = id
            self.name = name
            self.startedAt = startedAt
            self.finishedAt = finishedAt
            self.players = players
            let sortedQuests = quests.sorted { $0.index < $1.index }
            self.quests = sortedQuests
            self.status = status
            self.result = result
            if let selectedQuestID {
                self.selectedQuestID = selectedQuestID
            } else {
                self.selectedQuestID = sortedQuests.last(where: { $0.status != .notStarted })?.id
            }
        }

        var sortedQuests: [Quest] {
            quests.sorted { $0.index < $1.index }
        }
    }
}
