import SwiftUI

@MainActor
@Observable
final class GameStore {
    var game: DBModel.Game
    var players: [Player]
    private let container: DIContainer
    private var saveTask: Task<Void, Never>?

    init(players: [Player], container: DIContainer) {
        self.players = players
        self.container = container
        game = DBModel.Game.initial(players: players)
        initialGame()
    }

    func quest(id: UUID) -> DBModel.Quest? {
        return game.sortedQuests.first(where: { $0.id == id })
    }

    func team(id: UUID, in questID: UUID) -> DBModel.Team? { quest(id: questID)?.sortedTeams.first(where: { $0.id == id }) }

    // MARK: - Game Lifecycle

    func initialGame() {
        Task {
            if let lastGame = await getLastUnfinishedGame() {
                game = lastGame
            } else {
                createNewGame()
            }
        }
    }

    func createNewGame() {
        game = DBModel.Game.initial(players: players, status: .inProgress)
        game.startedAt = Date().toISOString()
        Task {
            await insertGame()
        }
    }

    func finishGame(_ result: GameResult? = .goodWinByFailedAss) {
        modifyAndSave {
            game.result = result
            game.status = .complete
            game.finishedAt = Date().toISOString()
        }
    }

    func validateGame() async {
        if game.status == .initial {
            return
        }

        do {
            let exists = try await container.interactors.games.gameExists(game)
            if !exists {
                createNewGame()
            }
        } catch {
            print("Failed to validate game: \(error)")
            createNewGame()
        }
    }

    // MARK: - Game Modifications

    func updateNumOfPlayers(_ number: Int) {
        players = Player.defaultPlayers(size: number)
        Task {
            createNewGame()
        }
    }

    func updateGameDetails(gameName: String) {
        modifyAndSave {
            game.name = gameName
        }
    }

    func startQuest(_ index: Int) {
        modifyAndSave {
            game.sortedQuests.first(where: { $0.index == index })?.status = .inProgress
            game.sortedQuests.first(where: { $0.index == index })?.sortedTeams.first(where: { $0.teamIndex == 0 })?.status = .inProgress
        }
    }

    func startTeam(questID: UUID, teamID: UUID) {
        modifyAndSave {
            team(id: teamID, in: questID)?.status = .inProgress
            quest(id: questID)?.selectedTeamID = teamID
        }
    }

    func updateTeam(
        questID: UUID,
        teamID: UUID,
        leader: Player? = nil,
        members: [Player]? = nil,
        votesByVoter: [PlayerID: VoteType]? = nil
    ) {
        modifyAndSave {
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
    }

    func finishTeam(questID: UUID, teamID: UUID) {
        modifyAndSave {
            team(id: teamID, in: questID)?.status = .finished
            let selectedTeam = team(id: teamID, in: questID) ?? DBModel.Team(roundIndex: 0, teamIndex: 0)
            let approvedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .approve ? $0.key : nil }).count
            let rejectedCount = Set(selectedTeam.votesByVoter.compactMap { $0.value == .reject ? $0.key : nil }).count

            let result = TeamResult(isApproved: approvedCount > rejectedCount, approvedCount: approvedCount, rejectedCount: rejectedCount)
            team(id: teamID, in: questID)?.result = result
        }
    }

    @discardableResult
    func updateQuestResult(questID: UUID, failCount: Int) -> Bool {
        modifyAndSave {
            quest(id: questID)?.status = .finished
            let result = DBModel.QuestResult(failCount: failCount)
            if failCount >= quest(id: questID)?.requiredFails ?? 1 {
                result.type = .fail
            } else {
                result.type = .success
            }
            quest(id: questID)?.result = result
        }

        let isFinished = checkGameFinish()
        return isFinished
    }

    func clearQuestResult(questID: UUID) {
        modifyAndSave {
            quest(id: questID)?.status = .inProgress
            quest(id: questID)?.result = nil
        }
    }

    // MARK: - Private Helper

    private func checkGameFinish() -> Bool {
        let quests = game.sortedQuests
        let successCount = quests.filter { $0.result?.type == .success }.count
        let failCount = quests.filter { $0.result?.type == .fail }.count

        if successCount >= 3 {
            game.status = .threeSuccesses
            return true
        }
        if failCount >= 3 {
            game.status = .threeFails
            return true
        }
        game.status = .inProgress
        return false
    }

    // MARK: - Persistence

    private func modifyAndSave(_ modification: () -> Void) {
        modification()
        saveDebounced()
    }

    private func saveDebounced() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await saveGame()
        }
    }

    private func insertGame() async {
        try? await container.interactors.games.insertGame(game)
    }

    private func getLastUnfinishedGame() async -> DBModel.Game? {
        return try? await container.interactors.games.getLastUnfinishedGame()
    }

    private func saveGame() async {
        try? await container.interactors.games.updateGame(game)
    }
}
