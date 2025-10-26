import SwiftUI

struct GameSectionView: View {
    let group: GameGroupViewData
    let onDelete: (IndexSet) -> Void

    var body: some View {
        Section {
            ForEach(group.games, id: \.id) { game in
                NavigationLink(value: game) {
                    GameCellView(game: game)
                }
            }
            .onDelete(perform: onDelete)
        } header: {
            GameSectionTitleView(date: group.date, count: group.games.count)
        }
    }
}
