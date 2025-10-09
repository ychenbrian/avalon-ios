import SwiftUI

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    let index: Int

    init(index: Int) {
        id = UUID()
        self.index = index
    }
}

@Observable
class Players {
    let players: [Player]

    init(players: [Player]) {
        self.players = players
    }
}

extension Players {
    static var preview: Players {
        return Players(players: Player.defaultPlayers)
    }
}
