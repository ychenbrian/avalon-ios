import SwiftUI

@MainActor
@Observable
final class GameStore {
    var game: GameViewData
    let players = Player.defaultPlayers

    init(game: GameViewData) { self.game = game }

    // Queries
    func round(id: UUID) -> RoundViewData? { game.rounds.first(where: { $0.id == id }) }
    func team(id: UUID, in roundID: UUID) -> TeamViewData? { round(id: roundID)?.teams.first(where: { $0.id == id }) }

    // Intents (mutations)
    @discardableResult
    func addRound(index: Int? = nil) -> RoundViewData {
        let index = index ?? nextRoundIndex()
        let round = RoundViewData(index: index)
        game.rounds.append(round)
        return round
    }

    func removeRound(id: UUID) {
        if let idx = game.rounds.firstIndex(where: { $0.id == id }) {
            game.rounds.remove(at: idx)
        }
    }

    @discardableResult
    func addTeam(to teamID: UUID, index _: Int? = nil) -> TeamViewData? {
        guard let round = round(id: teamID) else { return nil }
        let nextIndex = round.teams.count
        let team = TeamViewData(index: nextIndex)
        round.teams.append(team)
        return team
    }

    func removeTeam(_ teamID: UUID, from roundID: UUID) {
        guard let round = round(id: roundID),
              let idx = round.teams.firstIndex(where: { $0.id == teamID }) else { return }
        round.teams.remove(at: idx)
    }

    func startRound(_ index: Int) {
        game.rounds[index].status = .inProgress
        game.rounds[index].teams.first?.status = .inProgress
    }

    func updateTeam(
        roundID: UUID,
        teamID: UUID,
        leader: Player? = nil,
        members: [Player]? = nil,
        votesByVoter: [Player: VoteType]? = nil
    ) {
        guard let team = team(id: teamID, in: roundID) else { return }

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

    func finishTeam(roundID: UUID, teamID: UUID) {
        team(id: teamID, in: roundID)?.status = .finished
        let selectedTeam = team(id: teamID, in: roundID) ?? TeamViewData(index: 0)
        let approvedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .approve ? $0.key : nil }).count
        let rejectedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .reject ? $0.key : nil }).count

        let result = TeamVoteResult(isApproved: approvedCount > rejectedCount, approvedCount: approvedCount, rejectedCount: rejectedCount)
        team(id: teamID, in: roundID)?.result = result
    }

    func updateQuestResult(roundID: UUID, failCount: Int) {
        round(id: roundID)?.status = .finished
        var quest = QuestViewData(failCount: failCount)
        if failCount >= round(id: roundID)?.requiredFails ?? 1 {
            quest.result = .fail
        } else {
            quest.result = .success
        }
        round(id: roundID)?.quest = quest
    }

    private func nextRoundIndex() -> Int {
        return game.rounds.count
    }
}
