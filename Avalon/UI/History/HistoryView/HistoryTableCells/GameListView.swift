import SwiftUI

struct GroupedGameListView: View {
    let games: [AvalonGame]
    @Binding var navigationPath: NavigationPath
    let routingState: HistoryView.Routing
    let routingBinding: Binding<HistoryView.Routing>
    let onDelete: (GameGroupViewData, IndexSet) -> Void
    let onRefresh: () -> Void

    var body: some View {
        List {
            ForEach(groupedGames, id: \.date) { group in
                GameSectionView(
                    group: group,
                    onDelete: { offsets in
                        onDelete(group, offsets)
                    }
                )
            }
        }
        .refreshable {
            onRefresh()
        }
        .navigationDestination(for: AvalonGame.self) { _ in
            // TODO: navigate to game details screen
        }
        .onChange(of: routingState.gameID, initial: true) { _, gameID in
            guard let gameID,
                  let game = games.first(where: { $0.id == gameID })
            else { return }
            navigationPath.append(game)
        }
        .onChange(of: navigationPath) { _, path in
            if !path.isEmpty {
                routingBinding.wrappedValue.gameID = nil
            }
        }
    }

    private var groupedGames: [GameGroupViewData] {
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current

        var groups: [String: [AvalonGame]] = [:]

        for game in games {
            let key: String
            if let finishedAt = game.finishedAt,
               let date = formatter.date(from: finishedAt)
            {
                let dayStart = calendar.startOfDay(for: date)
                key = formatter.string(from: dayStart)
            } else {
                key = ""
            }
            groups[key, default: []].append(game)
        }

        return groups.map { key, games in
            GameGroupViewData(
                games: games.sorted { game1, game2 in
                    let date1 = getDate(from: game1.finishedAt ?? game1.startedAt)
                    let date2 = getDate(from: game2.finishedAt ?? game2.startedAt)
                    return date1 > date2
                }, date: key
            )
        }.sorted { group1, group2 in
            if group1.date == "" { return true }
            if group2.date == "" { return false }
            return group1.date > group2.date
        }
    }

    private func getDate(from isoString: String?) -> Date {
        guard let isoString = isoString else { return .distantPast }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: isoString) ?? .distantPast
    }
}
