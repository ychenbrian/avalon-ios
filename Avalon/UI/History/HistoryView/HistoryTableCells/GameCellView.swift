import SwiftUI

struct GameCellView: View {
    let game: AvalonGame

    var body: some View {
        Text(game.name.isEmpty ? String(localized: "game.untitledGame") : game.name)
    }
}
