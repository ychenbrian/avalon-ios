import Combine
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var context

    @Query(
        filter: #Predicate<DBModel.Game> { _ in true },
        sort: \.startedAt
    ) private var dbGames: [DBModel.Game]

    @State private var games: [DBModel.Game] = []
    @State private(set) var gamesState: Loadable<Void>
    @State private var canRequestPushPermission: Bool = false
    @State var navigationPath = NavigationPath()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.historyView)
    }

    @Environment(\.injected) private var injected: DIContainer

    init(state: Loadable<Void> = .notRequested) {
        _gamesState = .init(initialValue: state)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .onAppear {
                    games = dbGames
                }
                .onChange(of: dbGames) {
                    games = dbGames
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
            EmptyStateView()
        } else {
            GroupedGameListView(
                games: games,
                navigationPath: $navigationPath,
                routingState: routingState,
                routingBinding: routingBinding,
                onDelete: deleteGamesInSection,
                onRefresh: { loadGamesList(forceReload: true) }
            )
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
                        game
                    )
                    games.removeAll { $0.id == game.id }
                } catch {
                    print("Failed to delete game: \(error)")
                }
            }
        }
    }

    private func deleteGamesInSection(group: GameGroupViewData, at offsets: IndexSet) {
        Task {
            for index in offsets {
                let game = group.games[index]
                do {
                    try await injected.interactors.games.deleteGame(
                        game
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
    struct Routing: Equatable {}
}

// MARK: - State Updates

private extension HistoryView {
    private var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.historyView)
    }

    private var canRequestPushPermissionUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: AppState.permissionKeyPath(for: .pushNotifications))
            .map { $0 == .notRequested || $0 == .denied }
            .eraseToAnyPublisher()
    }
}
