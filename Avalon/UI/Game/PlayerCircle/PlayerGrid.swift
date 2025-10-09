import SwiftUI

struct PlayerGrid: View {
    let players: [Player]
    let selectedColor: Color
    let selected: (Player) -> Bool
    let action: (Player) -> Void

    init(
        players: [Player],
        selectedColor: Color = .blue,
        selected: @escaping (Player) -> Bool,
        action: @escaping (Player) -> Void
    ) {
        self.players = players
        self.selectedColor = selectedColor
        self.selected = selected
        self.action = action
    }

    var body: some View {
        let middleIndex = players.count / 2
        let firstHalf = Array(players.prefix(middleIndex))
        let secondHalf = Array(players.suffix(from: middleIndex))
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ForEach(firstHalf) { player in
                    PlayerCircleToggle(
                        name: "\(player.index + 1)",
                        isSelected: selected(player),
                        selectedColor: selectedColor
                    ) {
                        action(player)
                    }
                }
            }
            HStack {
                ForEach(secondHalf) { player in
                    PlayerCircleToggle(
                        name: "\(player.index + 1)",
                        isSelected: selected(player),
                        selectedColor: selectedColor
                    ) {
                        action(player)
                    }
                }
            }
        }
    }
}

#Preview {
    HStack {
        PlayerGrid(players: Player.defaultPlayers, selected: { _ in [true, false].randomElement() ?? true }, action: { _ in })
    }
}
