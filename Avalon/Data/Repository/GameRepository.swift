import Foundation
import SwiftData

protocol GamesDBRepository {
    func insert(game: DBModel.Game) async throws -> PersistentIdentifier
    func store(games: [DBModel.Game]) async throws
    func getLastUnfinishedGame() async throws -> DBModel.Game?
    func exists(id: PersistentIdentifier) async throws -> Bool
    func get(id: PersistentIdentifier) async throws -> DBModel.Game?
    func update(with gameData: DBModel.Game) async throws
    func delete(id: PersistentIdentifier) async throws
    func deleteAll() async throws
}

extension MainDBRepository: GamesDBRepository {
    func insert(game: DBModel.Game) async throws -> PersistentIdentifier {
        try modelContext.transaction {
            modelContext.insert(game)
        }

        return game.persistentModelID
    }

    func store(games: [DBModel.Game]) async throws {
        try modelContext.transaction {
            for game in games {
                modelContext.insert(game)
            }
        }
    }

    func getLastUnfinishedGame() async throws -> DBModel.Game? {
        let descriptor = FetchDescriptor<DBModel.Game>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        let games = try modelContext.fetch(descriptor)
        return games.filter { $0.startedAt != nil }.first
    }

    func exists(id: PersistentIdentifier) async throws -> Bool {
        let descriptor = FetchDescriptor<DBModel.Game>()
        do {
            let games = try modelContext.fetch(descriptor)
            return games.contains(where: { $0.persistentModelID == id })
        } catch {
            return false
        }
    }

    func get(id: PersistentIdentifier) async throws -> DBModel.Game? {
        let descriptor = FetchDescriptor<DBModel.Game>()
        do {
            let games = try modelContext.fetch(descriptor)
            return games.first(where: { $0.persistentModelID == id })
        } catch {
            return nil
        }
    }

    func update(with gameData: DBModel.Game) async throws {
        guard let existingGame = modelContext.model(for: gameData.persistentModelID) as? DBModel.Game else {
            throw GamesError.gameNotFound
        }

        existingGame.name = gameData.name
        existingGame.startedAt = gameData.startedAt
        existingGame.finishedAt = gameData.finishedAt
        existingGame.players = gameData.players
        existingGame.quests = gameData.quests
        existingGame.status = gameData.status
        existingGame.result = gameData.result

        try modelContext.save()
    }

    func delete(id: PersistentIdentifier) async throws {
        guard let gameToDelete = modelContext.model(for: id) as? DBModel.Game else {
            throw GamesError.gameNotFound
        }

        modelContext.delete(gameToDelete)
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: DBModel.Game.self)
        try modelContext.save()
    }
}

enum GamesError: Error {
    case missingPersistentID
    case gameNotFound
}
