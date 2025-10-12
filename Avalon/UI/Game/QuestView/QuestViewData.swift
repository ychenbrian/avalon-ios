import SwiftUI

@Observable
final class QuestViewData: Identifiable {
    let id: UUID
    var index: Int
    var status: QuestStatus = .notStarted
    var result: ResultViewData?
    var teams: [TeamViewData]
    var selectedTeamID: UUID?

    var requiredTeamSize: Int { [3, 4, 4, 5, 5][index] }
    var requiredFails: Int { index == 3 ? 2 : 1 }

    init(id: UUID = UUID(), index: Int, teams: [TeamViewData] = []) {
        self.id = id
        self.index = index
        self.teams = teams
        selectedTeamID = teams.first?.id
    }

    init(quest: Quest) {
        id = quest.id
        index = quest.index
        status = quest.status
        result = ResultViewData(quest: quest.quest)
        teams = quest.teams.map(TeamViewData.init(team:))
    }
}
