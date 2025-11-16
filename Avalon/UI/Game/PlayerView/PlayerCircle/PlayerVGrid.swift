import SwiftUI

struct PlayerVGrid: View {
    enum Half {
        case firstHalf
        case secondHalf
    }

    let players: [Player]
    let selectedColor: Color
    let half: Half
    let selected: (Player) -> Bool
    let action: (Player) -> Void

    init(
        players: [Player],
        selectedColor: Color = .appColor(.selectedColor),
        half: Half = .firstHalf,
        selected: @escaping (Player) -> Bool,
        action: @escaping (Player) -> Void
    ) {
        self.players = players
        self.selectedColor = selectedColor
        self.half = half
        self.selected = selected
        self.action = action
    }

    var body: some View {
        let middleIndex = (players.count + 1) / 2
        let firstHalf = Array(players.prefix(middleIndex))
        let secondHalf = Array(players.suffix(from: middleIndex))
        VStack(alignment: .leading, spacing: 16) {
            ForEach(half == .firstHalf ? firstHalf : secondHalf) { player in
                PlayerCircleToggle(
                    name: "\(player.index + 1)",
                    isSelected: selected(player),
                    size: 56.0,
                    selectedColor: selectedColor
                ) {
                    action(player)
                }
            }
        }
    }
}

#Preview {
    HStack {
        PlayerVGrid(players: Player.defaultPlayers(), selected: { _ in [true, false].randomElement() ?? true }, action: { _ in })
    }
}
