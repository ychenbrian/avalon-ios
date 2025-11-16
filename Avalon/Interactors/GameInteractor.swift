import SwiftData
import SwiftUI

protocol GamesInteractor {
    func insertGame(_ gameData: DBModel.Game) async throws -> DBModel.Game
    func getGame(_ gameData: DBModel.Game) async throws -> DBModel.Game?
    func getGameByID(_ gameID: UUID) async throws -> DBModel.Game?
    func getLastUnfinishedGame() async throws -> DBModel.Game?
    func gameExists(_ gameData: DBModel.Game) async throws -> Bool
    func updateGame(_ gameData: DBModel.Game) async throws
    func deleteGame(_ gameData: DBModel.Game) async throws
    func deleteAllGames() async throws
}

struct RealGamesInteractor: GamesInteractor {
    let dbRepository: GamesDBRepository

    func insertGame(_ gameData: DBModel.Game) async throws -> DBModel.Game {
        let savedGame = gameData
        return try await dbRepository.insert(game: savedGame)
    }

    func getGame(_ gameData: DBModel.Game) async throws -> DBModel.Game? {
        return try await dbRepository.get(id: gameData.persistentModelID)
    }

    func getGameByID(_ gameID: UUID) async throws -> DBModel.Game? {
        return try await dbRepository.get(gameID: gameID)
    }

    func getLastUnfinishedGame() async throws -> DBModel.Game? {
        if let game = try await dbRepository.getLastUnfinishedGame() {
            return game
        } else {
            return nil
        }
    }

    func gameExists(_ gameData: DBModel.Game) async throws -> Bool {
        return try await dbRepository.exists(id: gameData.persistentModelID)
    }

    func updateGame(_ gameData: DBModel.Game) async throws {
        try await dbRepository.update(with: gameData)
    }

    func deleteGame(_ gameData: DBModel.Game) async throws {
        try await dbRepository.delete(id: gameData.persistentModelID)
    }

    func deleteAllGames() async throws {
        try await dbRepository.deleteAll()
    }
}

struct StubGamesInteractor: GamesInteractor {
    func insertGame(_: DBModel.Game) async throws -> DBModel.Game { return .empty() }
    func getGame(_: DBModel.Game) async throws -> DBModel.Game? { return nil }
    func getGameByID(_: UUID) async throws -> DBModel.Game? { return nil }
    func getLastUnfinishedGame() async throws -> DBModel.Game? { return nil }
    func gameExists(_: DBModel.Game) async throws -> Bool { return true }
    func updateGame(_: DBModel.Game) async throws {}
    func deleteGame(_: DBModel.Game) async throws {}
    func deleteAllGames() async throws {}
}
