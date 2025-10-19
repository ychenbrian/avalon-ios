import Foundation
import SwiftData

protocol GamesDBRepository {
    func insert(game: AvalonGame) async throws -> PersistentIdentifier
    func store(games: [AvalonGame]) async throws
    func getLastUnfinishedGame() async throws -> AvalonGame?
    func update(with gameData: GameViewData) async throws
}

extension MainDBRepository: GamesDBRepository {
    func insert(game: AvalonGame) async throws -> PersistentIdentifier {
        try modelContext.transaction {
            modelContext.insert(game)
        }

        return game.persistentModelID
    }

    func store(games: [AvalonGame]) async throws {
        try modelContext.transaction {
            for game in games {
                modelContext.insert(game)
            }
        }
    }

    func getLastUnfinishedGame() async throws -> AvalonGame? {
        let descriptor = FetchDescriptor<AvalonGame>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        let games = try modelContext.fetch(descriptor)
        return games.filter { $0.startedAt != nil }.first
    }

    func update(with gameData: GameViewData) async throws {
        guard let persistentID = gameData.persistentModelID else {
            throw GamesError.missingPersistentID
        }
        guard let existingGame = modelContext.model(for: persistentID) as? AvalonGame else {
            throw GamesError.gameNotFound
        }

        existingGame.name = gameData.name
        existingGame.startedAt = gameData.startedAt
        existingGame.finishedAt = gameData.finishedAt
        existingGame.players = gameData.players
        existingGame.quests = gameData.quests.map { $0.toQuest() }
        existingGame.status = gameData.status
        existingGame.result = gameData.result

        try modelContext.save()
    }
}

enum GamesError: Error {
    case missingPersistentID
    case gameNotFound
}
