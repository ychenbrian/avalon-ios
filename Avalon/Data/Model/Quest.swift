import Foundation
import SwiftData
import SwiftUI

// MARK: - DBModel

extension DBModel {
    @Model
    final class Quest {
        var id = UUID()
        var index: Int
        var numOfPlayers: Int
        var status: QuestStatus?
        var result: QuestResult?
        var teams: [Team]
        var selectedTeamID: UUID?

        init(
            id: UUID = UUID(),
            index: Int,
            numOfPlayers: Int,
            status: QuestStatus,
            result: QuestResult? = nil,
            teams: [Team],
            selectedTeamID: TeamID? = nil
        ) {
            self.id = id
            self.index = index
            self.numOfPlayers = numOfPlayers
            self.status = status
            self.result = result
            let sortedTeams = teams.sorted { $0.teamIndex < $1.teamIndex }
            self.teams = sortedTeams
            self.selectedTeamID = selectedTeamID ?? sortedTeams.last(where: { $0.status != .notStarted })?.id
        }

        var sortedTeams: [Team] {
            teams.sorted { $0.teamIndex < $1.teamIndex }
        }

        var requiredTeamSize: Int { GameRules.getRequiredTeamSize(numOfPlayers: numOfPlayers, questIndex: index) }

        var requiredFails: Int { GameRules.getRequiredFails(numOfPlayers: numOfPlayers, questIndex: index) }
    }
}
