import Foundation
import SwiftData

protocol GamesDBRepository {
    func insert(game: AvalonGame) async throws
    func store(games: [AvalonGame]) async throws
    func getLastUnfinishedGame() async throws -> AvalonGame?
    func save() async throws
}

extension MainDBRepository: GamesDBRepository {
    func insert(game: AvalonGame) async throws {
        try modelContext.transaction {
            modelContext.insert(game)
        }
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
        for game in games {
            print("Game: \(game.name), startedAt: \(game.startedAt ?? "Null")")
        }

        return games.filter { $0.startedAt != nil }.first
    }

    func save() async throws {
        try modelContext.save()
    }
}
