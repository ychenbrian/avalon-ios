import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var routingState = AppState.ViewRouting()

    private var tabSelection: Binding<AppState.Tab> {
        $routingState.selectedTab
            .dispatched(to: injected.appState, \.routing.selectedTab)
    }

    var body: some View {
        TabView(selection: tabSelection) {
            GameView(interactor: injected.interactors.games)
                .tabItem {
                    Label("navigation.tab.game", systemImage: "gamecontroller")
                }
                .tag(AppState.Tab.game)

            HistoryView()
                .tabItem {
                    Label("navigation.tab.history", systemImage: "clock")
                }
                .tag(AppState.Tab.history)

            RulesView()
                .tabItem {
                    Label("navigation.tab.rule", systemImage: "book")
                }
                .tag(AppState.Tab.rules)

            SettingsView()
                .tabItem {
                    Label("navigation.tab.settings", systemImage: "gearshape")
                }
                .tag(AppState.Tab.settings)
        }
        .onReceive(injected.appState.updates(for: \.routing)) {
            routingState = $0
        }
    }
}
