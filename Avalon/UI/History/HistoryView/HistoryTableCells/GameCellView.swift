import SwiftUI

struct GameCellView: View {
    let game: DBModel.Game

    var body: some View {
        Text(game.name.isEmpty ? String(localized: "game.untitledGame") : game.name)
    }
}
