import Foundation

final class MockGamesInteractor: GamesInteractor {
    private var store: DBModel.Game

    init(seed: DBModel.Game = .empty()) { store = seed }

    func getGame(_: DBModel.Game) async throws -> DBModel.Game? { store }
    func gameExists(_: DBModel.Game) async throws -> Bool { return true }
    func deleteGame(_: DBModel.Game) async throws {}
    func deleteAllGames() async throws {}
    func getLastUnfinishedGame() async throws -> DBModel.Game? { store }
    func updateGame(_ game: DBModel.Game) async throws { store = game }
    func insertGame(_ game: DBModel.Game) async throws -> DBModel.Game { store = game; return game }
}
