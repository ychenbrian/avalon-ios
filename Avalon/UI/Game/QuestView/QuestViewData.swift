import SwiftUI

@Observable
final class QuestViewData: Identifiable {
    let id: UUID
    let index: Int
    let numOfPlayers: Int
    var status: QuestStatus = .notStarted
    var result: ResultViewData?
    var teams: [TeamViewData]
    var selectedTeamID: UUID?

    var requiredTeamSize: Int { GameRules.getRequiredTeamSize(numOfPlayers: numOfPlayers, questIndex: index) }
    var requiredFails: Int { GameRules.getRequiredFails(numOfPlayers: numOfPlayers, questIndex: index) }

    init(id: UUID = UUID(), index: Int, numOfPlayers: Int, teams: [TeamViewData] = []) {
        self.id = id
        self.index = index
        self.numOfPlayers = numOfPlayers
        self.teams = teams
        selectedTeamID = teams.first?.id
    }

    init(quest: Quest) {
        id = quest.id
        index = quest.index
        status = quest.status
        numOfPlayers = quest.numOfPlayers
        result = ResultViewData(quest: quest.quest)
        teams = quest.teams.map(TeamViewData.init(team:))
    }
}
