import SwiftUI

protocol GamesInteractor {
    func insertGame(_ gameData: GameViewData) async throws
    func getLastUnfinishedGame() async throws -> GameViewData?
    func save() async throws
}

struct RealGamesInteractor: GamesInteractor {
    let dbRepository: GamesDBRepository

    func insertGame(_ game: GameViewData) async throws {
        let savedGame = game.toAvalonGame()
        try await dbRepository.insert(game: savedGame)
    }

    func getLastUnfinishedGame() async throws -> GameViewData? {
        if let game = try await dbRepository.getLastUnfinishedGame() {
            return GameViewData(game: game)
        } else {
            return nil
        }
    }

    func save() async throws {
        try await dbRepository.save()
    }
}

struct StubGamesInteractor: GamesInteractor {
    func insertGame(_: GameViewData) async throws {}

    func getLastUnfinishedGame() async throws -> GameViewData? {
        return nil
    }

    func save() async throws {}
}
