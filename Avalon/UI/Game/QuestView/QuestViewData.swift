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
        let sortedTeams = teams.sorted { $0.teamIndex < $1.teamIndex }
        self.teams = sortedTeams
        selectedTeamID = sortedTeams.last(where: { $0.status != .notStarted })?.id
    }

    init(quest: Quest, players: [Player]) {
        id = quest.id
        index = quest.index
        status = quest.status ?? .notStarted
        numOfPlayers = quest.numOfPlayers
        result = ResultViewData(quest: quest.result)
        let sortedTeams = quest.teams.sorted { $0.teamIndex < $1.teamIndex }
        teams = sortedTeams.map { TeamViewData(team: $0, players: players) }
        selectedTeamID = sortedTeams.last(where: { $0.status != .notStarted })?.id
    }

    func toQuest() -> Quest {
        Quest(
            id: id,
            index: index,
            numOfPlayers: numOfPlayers,
            status: status,
            result: result?.toQuestResult(),
            teams: teams.map { $0.toTeam() }
        )
    }
}
