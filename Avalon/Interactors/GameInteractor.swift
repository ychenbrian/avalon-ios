import SwiftUI

protocol GamesInteractor {
    func insertGame(_ gameData: GameViewData) async throws
    func getLastUnfinishedGame() async throws -> GameViewData?
    func updateGame(_ gameData: GameViewData) async throws
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

    func updateGame(_ gameData: GameViewData) async throws {
        try await dbRepository.update(with: gameData)
    }
}

struct StubGamesInteractor: GamesInteractor {
    func insertGame(_: GameViewData) async throws {}

    func getLastUnfinishedGame() async throws -> GameViewData? {
        return nil
    }

    func updateGame(_: GameViewData) async throws {}
}
