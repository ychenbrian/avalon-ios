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
            DateTitleCell(date: group.date)
        }
    }
}
