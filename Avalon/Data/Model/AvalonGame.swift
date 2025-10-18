import Foundation
import SwiftData
import SwiftUI

@Model
final class AvalonGame {
    var id: UUID
    var name: String
    var startedAt: String?
    var finishedAt: String?
    var players: [Player]
    var quests: [Quest]
    var status: GameStatus
    var result: GameResult?

    init(id: UUID = UUID(), name: String = generateReference(), startedAt: String? = nil, finishedAt: String? = nil, players: [Player] = [], quests: [Quest] = [], status: GameStatus = .inProgress, result: GameResult? = nil) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.players = players
        self.quests = quests
        self.status = status
        self.result = result
    }
}
