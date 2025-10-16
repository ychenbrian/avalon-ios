import Foundation
import SwiftData
import SwiftUI

@Model
final class Quest {
    var id = UUID()
    var index: Int
    var numOfPlayers: Int
    var status: QuestStatus?
    var result: QuestResult?
    var teams: [Team]

    init(id: UUID = UUID(), index: Int, numOfPlayers: Int, status: QuestStatus, result: QuestResult? = nil, teams: [Team]) {
        self.id = id
        self.index = index
        self.numOfPlayers = numOfPlayers
        self.status = status
        self.result = result
        self.teams = teams
    }
}
