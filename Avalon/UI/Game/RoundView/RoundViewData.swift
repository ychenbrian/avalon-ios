import SwiftUI

@Observable
final class RoundViewData: Identifiable {
    let id: UUID
    var index: Int
    var status: RoundStatus = .notStarted
    var quest: QuestViewData?
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

    init(round: GameRound) {
        id = round.id
        index = round.index
        status = round.status
        quest = QuestViewData(quest: round.quest)
        teams = round.teamVotes.map(TeamViewData.init(team:))
    }
}
