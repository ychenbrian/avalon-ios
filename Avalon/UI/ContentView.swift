import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var store = GameStore(game: GameViewData(game: AvalonGame.initial()))

    var body: some View {
        TabView {
            GameView()
                .environment(store)
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
    }
}
