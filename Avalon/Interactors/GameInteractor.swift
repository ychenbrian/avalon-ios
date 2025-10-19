import SwiftUI

protocol GamesInteractor {
    func insertGame(_ gameData: GameViewData) async throws
    func getLastUnfinishedGame() async throws -> GameViewData?
    func gameExists(_ gameData: GameViewData) async throws -> Bool
    func updateGame(_ gameData: GameViewData) async throws
    func deleteGame(_ gameData: GameViewData) async throws
    func deleteAllGames() async throws
}

struct RealGamesInteractor: GamesInteractor {
    let dbRepository: GamesDBRepository

    func insertGame(_ gameData: GameViewData) async throws {
        let savedGame = gameData.toAvalonGame()
        let persistentID = try await dbRepository.insert(game: savedGame)
        gameData.persistentModelID = persistentID
    }

    func getLastUnfinishedGame() async throws -> GameViewData? {
        if let game = try await dbRepository.getLastUnfinishedGame() {
            return GameViewData(game: game)
        } else {
            return nil
        }
    }

    func gameExists(_ gameData: GameViewData) async throws -> Bool {
        guard let persistentID = gameData.persistentModelID else {
            return false
        }
        return try await dbRepository.exists(id: persistentID)
    }

    func updateGame(_ gameData: GameViewData) async throws {
        try await dbRepository.update(with: gameData)
    }

    func deleteGame(_ gameData: GameViewData) async throws {
        guard let persistentID = gameData.persistentModelID else {
            throw GamesError.missingPersistentID
        }
        try await dbRepository.delete(id: persistentID)
    }

    func deleteAllGames() async throws {
        try await dbRepository.deleteAll()
    }
}

struct StubGamesInteractor: GamesInteractor {
    func insertGame(_: GameViewData) async throws {}
    func getLastUnfinishedGame() async throws -> GameViewData? { return nil }
    func gameExists(_: GameViewData) async throws -> Bool { return true }
    func updateGame(_: GameViewData) async throws {}
    func deleteGame(_: GameViewData) async throws {}
    func deleteAllGames() async throws {}
}
