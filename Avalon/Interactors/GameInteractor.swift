import SwiftUI

protocol GamesInteractor {
    func refreshGamesList() async throws
}

struct RealGamesInteractor: GamesInteractor {
    let dbRepository: GamesDBRepository

    func refreshGamesList() async throws {
        let game = GameViewData(game: AvalonGame.random())
        try await dbRepository.store(games: [game])
    }
}

struct StubGamesInteractor: GamesInteractor {
    func refreshGamesList() async throws {}
}
