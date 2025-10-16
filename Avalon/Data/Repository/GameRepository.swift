import Foundation
import SwiftData

protocol GamesDBRepository {
    func store(games: [GameViewData]) async throws
}

extension MainDBRepository: GamesDBRepository {
    func store(games: [GameViewData]) async throws {
        try modelContext.transaction {
            games
                .map { $0.toAvalonGame() }
                .forEach {
                    modelContext.insert($0)
                }
        }
    }
}
