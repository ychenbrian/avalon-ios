import Combine
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var ctx

    @State private var games: [AvalonGame] = []
    @State private(set) var gamesState: Loadable<Void>
    @State private var canRequestPushPermission: Bool = false
    @State var navigationPath = NavigationPath()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.gameHistory)
    }

    @Environment(\.injected) private var injected: DIContainer

    init(state: Loadable<Void> = .notRequested) {
        _gamesState = .init(initialValue: state)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .query(searchText: "", results: $games) { _ in
                    Query(filter: #Predicate<AvalonGame> { _ in
                        return true
                    }, sort: \AvalonGame.startedAt)
                }
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .flipsForRightToLeftLayoutDirection(true)
    }

    @ViewBuilder private var content: some View {
        switch gamesState {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case .loaded:
            loadedView()
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Loading Content

private extension HistoryView {
    func defaultView() -> some View {
        Text("").onAppear {
            if !games.isEmpty {
                gamesState = .loaded(())
            }
            loadGamesList(forceReload: false)
        }
    }

    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            loadGamesList(forceReload: true)
        })
    }
}

// MARK: - Displaying Content

@MainActor
private extension HistoryView {
    @ViewBuilder
    func loadedView() -> some View {
        if games.isEmpty {
            Text("historyView.noGamesFound")
                .font(.footnote)
        } else {
            List {
                ForEach(games, id: \.id) { game in
                    NavigationLink(value: game) {
                        Text(game.name.isEmpty ? String(localized: "game.untitledGame") : game.name)
                    }
                }
                .onDelete(perform: deleteGames)
            }
            .refreshable {
                loadGamesList(forceReload: true)
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
    }
}

// MARK: - Database

private extension HistoryView {
    private func loadGamesList(forceReload: Bool) {
        guard forceReload || games.isEmpty else { return }
        $gamesState.load {
            // TODO: refresh the game list
        }
    }

    private func deleteGames(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let game = games[index]
                do {
                    try await injected.interactors.games.deleteGame(
                        GameViewData(game: game)
                    )
                    games.removeAll { $0.id == game.id }
                } catch {
                    print("Failed to delete game: \(error)")
                }
            }
        }
    }
}

// MARK: - Routing

extension HistoryView {
    struct Routing: Equatable {
        var gameID: UUID?
    }
}

// MARK: - State Updates

private extension HistoryView {
    private var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.gameHistory)
    }

    private var canRequestPushPermissionUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: AppState.permissionKeyPath(for: .pushNotifications))
            .map { $0 == .notRequested || $0 == .denied }
            .eraseToAnyPublisher()
    }
}
