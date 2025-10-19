import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var gameStore: GameStore?

    var body: some View {
        TabView {
            GameView()
                .environment(gameStore)
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            RulesView()
                .tabItem {
                    Label("Rules", systemImage: "book")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            if gameStore == nil {
                gameStore = GameStore(players: Player.defaultPlayers(size: 7), container: injected)
            }
        }
    }
}
