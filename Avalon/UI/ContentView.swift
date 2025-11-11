import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        TabView {
            GameView(interactor: injected.interactors.games)
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
