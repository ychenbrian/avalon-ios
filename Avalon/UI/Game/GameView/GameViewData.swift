import SwiftUI

@Observable
final class GameViewData: Identifiable {
    let id: UUID
    var name: String
    var rounds: [RoundViewData]
    var selectedRoundID: UUID?

    init(id: UUID = UUID(), name: String, rounds: [RoundViewData] = []) {
        self.id = id
        self.name = name
        self.rounds = rounds
        selectedRoundID = rounds.first?.id
    }

    init(game: AvalonGame) {
        id = game.id
        name = "Game 1"
        rounds = game.rounds.map(RoundViewData.init(round:))
        selectedRoundID = rounds.first?.id
    }
}
