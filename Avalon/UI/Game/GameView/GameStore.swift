import SwiftUI

@MainActor
@Observable
final class GameStore {
    var game: GameViewData
    let players = Player.defaultPlayers

    init(game: GameViewData) { self.game = game }

    // Queries
    func quest(id: UUID) -> QuestViewData? { game.quests.first(where: { $0.id == id }) }
    func team(id: UUID, in questID: UUID) -> TeamViewData? { quest(id: questID)?.teams.first(where: { $0.id == id }) }

    // Intents (mutations)
    func initialGame() {
        game = GameViewData(game: AvalonGame.initial())
    }

    @discardableResult
    func addQuest(index: Int? = nil) -> QuestViewData {
        let index = index ?? game.quests.count
        let quest = QuestViewData(index: index)
        game.quests.append(quest)
        return quest
    }

    func removeQuest(id: UUID) {
        if let idx = game.quests.firstIndex(where: { $0.id == id }) {
            game.quests.remove(at: idx)
        }
    }

    @discardableResult
    func addTeam(to teamID: UUID, index _: Int? = nil) -> TeamViewData? {
        guard let quest = quest(id: teamID) else { return nil }
        let nextIndex = quest.teams.count
        let team = TeamViewData(index: nextIndex)
        quest.teams.append(team)
        return team
    }

    func removeTeam(_ teamID: UUID, from questID: UUID) {
        guard let quest = quest(id: questID),
              let idx = quest.teams.firstIndex(where: { $0.id == teamID }) else { return }
        quest.teams.remove(at: idx)
    }

    func startQuest(_ index: Int) {
        game.quests[index].status = .inProgress
        game.quests[index].teams.first?.status = .inProgress
    }

    func updateTeam(
        questID: UUID,
        teamID: UUID,
        leader: Player? = nil,
        members: [Player]? = nil,
        votesByVoter: [Player: VoteType]? = nil
    ) {
        guard let team = team(id: teamID, in: questID) else { return }

        if let leader = leader {
            team.leader = leader
        }

        if let members = members {
            team.members = members
        }

        if let votesByVoter = votesByVoter {
            team.votesByVoter = votesByVoter
        }
    }

    func finishTeam(questID: UUID, teamID: UUID) {
        team(id: teamID, in: questID)?.status = .finished
        let selectedTeam = team(id: teamID, in: questID) ?? TeamViewData(index: 0)
        let approvedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .approve ? $0.key : nil }).count
        let rejectedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .reject ? $0.key : nil }).count

        let result = TeamResult(isApproved: approvedCount > rejectedCount, approvedCount: approvedCount, rejectedCount: rejectedCount)
        team(id: teamID, in: questID)?.result = result
    }

    func updateQuestResult(questID: UUID, failCount: Int) {
        quest(id: questID)?.status = .finished
        let result = ResultViewData(failCount: failCount)
        if failCount >= quest(id: questID)?.requiredFails ?? 1 {
            result.type = .fail
        } else {
            result.type = .success
        }
        quest(id: questID)?.result = result
    }
}
