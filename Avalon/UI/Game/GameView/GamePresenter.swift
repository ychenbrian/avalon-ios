import Foundation
import SwiftUI

@MainActor
final class GamePresenter: ObservableObject {
    // MARK: - Published State

    @Published var players: [Player] = Player.defaultPlayers()
    @Published var game: DBModel.Game = .empty()
    @Published private(set) var gameState: Loadable<Void> = .notRequested
    @Published private(set) var isSaving = false
    @Published var saveError: Error?

    // MARK: - Derived

    var selectedQuestID: UUID? { game.selectedQuestID }
    var isDirty: Bool { game != lastSaved }

    // MARK: - Dependencies

    private let interactor: GamesInteractor

    // MARK: - Internal State

    private var lastSaved: DBModel.Game = .empty()
    private var loadBag = CancelBag()

    // MARK: - Init

    init(interactor: GamesInteractor) {
        self.interactor = interactor
    }

    // MARK: - Accessors

    func quest(id: UUID) -> DBModel.Quest? {
        game.sortedQuests.first(where: { $0.id == id })
    }

    func team(id: UUID, in questID: UUID) -> DBModel.Team? {
        quest(id: questID)?.sortedTeams.first(where: { $0.id == id })
    }

    // MARK: - Persistence

    func loadIfNeeded() async {
        guard case .notRequested = gameState else { return }
        await load()
    }

    func load() async {
        loadBag.cancel()
        let bag = CancelBag()
        loadBag = bag
        gameState = .isLoading(last: nil, cancelBag: bag)

        do {
            let dbGame = try await interactor.getLastUnfinishedGame() ?? .empty()
            game = dbGame
            lastSaved = dbGame
            players = dbGame.players
            gameState = .loaded(())
        } catch {
            gameState = .failed(error)
        }
    }

    func save() async {
        guard isDirty, !isSaving else { return }
        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            try await interactor.updateGame(game)
            lastSaved = game
        } catch {
            saveError = error
            game = lastSaved
        }
    }

    // MARK: - Game Modifications

    func createNewGame(resetPlayersToDefault: Bool = true, count: Int? = nil) async {
        let newPlayers = resetPlayersToDefault
            ? Player.defaultPlayers(size: count ?? players.count)
            : players.map { $0.detached() }

        let draft = DBModel.Game.initial(players: newPlayers, status: .inProgress)
        draft.startedAt = Date().toISOString()

        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            let saved = try await interactor.insertGame(draft)
            withAnimation {
                players = newPlayers
                game = saved
                lastSaved = saved
            }
        } catch {
            saveError = error
        }
    }

    func updateNumOfPlayers(_ number: Int) async {
        await createNewGame(resetPlayersToDefault: true, count: number)
    }

    func updateGameDetails(gameName: String) async {
        game.name = gameName
        await save()
    }

    func startTeam(questID: UUID, teamID: UUID) async {
        guard let quest = quest(id: questID), let t = team(id: teamID, in: questID) else { return }
        t.status = .inProgress
        quest.selectedTeamID = teamID
        await save()
    }

    func startQuest(_ index: Int) async {
        guard let quest = game.sortedQuests.first(where: { $0.index == index }) else { return }
        quest.status = .inProgress
        quest.sortedTeams.first(where: { $0.teamIndex == 0 })?.status = .inProgress
        await save()
    }

    func finishGame(_ result: GameResult? = .goodWinByFailedAss) async {
        game.result = result
        game.status = .complete
        game.finishedAt = Date().toISOString()
        await save()
    }

    func updateTeam(
        questID: UUID,
        teamID: UUID,
        leader: Player? = nil,
        members: [Player]? = nil,
        votesByVoter: [PlayerID: VoteType]? = nil
    ) async {
        guard let team = team(id: teamID, in: questID) else { return }
        if let leader { team.leader = leader }
        if let members { team.members = members }
        if let votesByVoter { team.votesByVoter = votesByVoter }
        await save()
    }

    @discardableResult
    func updateQuestResult(questID: UUID, failCount: Int) async -> Bool {
        guard let quest = quest(id: questID) else { return false }

        quest.status = .finished
        let result = DBModel.QuestResult(failCount: failCount)
        let requiredFails = quest.requiredFails
        result.type = (failCount >= requiredFails) ? .fail : .success
        quest.result = result

        await save()
        return checkGameFinish()
    }

    func clearQuestResult(questID: UUID) async {
        guard let quest = quest(id: questID) else { return }
        quest.status = .inProgress
        quest.result = nil
        await save()
    }

    func finishTeam(questID: UUID, teamID: UUID) async {
        guard let team = team(id: teamID, in: questID) else { return }
        team.status = .finished

        let votes = team.votesByVoter.values
        let approvedCount = votes.filter { $0 == .approve }.count
        let rejectedCount = votes.filter { $0 == .reject }.count

        let result = TeamResult(
            isApproved: approvedCount > rejectedCount,
            approvedCount: approvedCount,
            rejectedCount: rejectedCount
        )
        team.result = result
        await save()
    }

    // MARK: - Helpers

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
}

// MARK: - Preview

extension GamePresenter {
    @MainActor
    static func preview() -> GamePresenter {
        var game: DBModel.Game = .random()

        let interactor = MockGamesInteractor(seed: game)
        let presenter = GamePresenter(interactor: interactor)
        presenter.players = game.players
        presenter.game = game
        presenter.gameState = .loaded(())
        return presenter
    }
}
