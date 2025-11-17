import Combine
import SwiftUI

struct PlayerView: View {
    @Environment(\.injected) private var injected: DIContainer

    @State var navigationPath = NavigationPath()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.playerView)
    }

    @StateObject private var presenter: GamePresenter
    @State private var selectedPlayer: Player?

    init(game: DBModel.Game) {
        let presenter = GamePresenter(game: game)
        _presenter = StateObject(wrappedValue: presenter)
    }

    init(presenter: GamePresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        content
            .navigationTitle(
                String(
                    format: NSLocalizedString("playerView.title.format", comment: "Player number in list"),
                    (selectedPlayer?.index ?? 0) + 1
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(presenter)
            .toolbar(.hidden, for: .tabBar)
            .onReceive(routingUpdate) { routingState = $0 }
            .onAppear {
                selectedPlayer = presenter.game.players.first { $0.index == 0 }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch presenter.gameState {
        case .notRequested:
            defaultView
        case .isLoading:
            loadingView
        case .loaded:
            loadedView
        case let .failed(error):
            failedView(error)
        }
    }

    private func sortedPlayer() -> [Player] {
        return presenter.players.sorted { $0.index < $1.index }
    }
}

// MARK: - Displaying Content

private extension PlayerView {
    @ViewBuilder
    var loadedView: some View {
        if presenter.game.status == .initial {
            EmptyStateView()
        } else {
            ScrollView {
                VStack {
                    PlayerGrid(
                        players: sortedPlayer(),
                        selectedColor: .appColor(.selectedColor),
                        selected: { selectedPlayer == $0 },
                        action: { player in
                            selectedPlayer = player
                        }
                    )

                    if let selectedPlayer {
                        VStack {
                            ForEach(presenter.game.sortedQuests, id: \.id) { quest in
                                if quest.status != .notStarted {
                                    PlayerQuestView(quest: quest, player: selectedPlayer)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }

    var defaultView: some View {
        Text("Default View")
    }

    var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {})
    }
}

// MARK: - Routing

extension PlayerView {
    struct Routing: Equatable {
        var gameID: UUID?
    }
}

// MARK: - State Updates

private extension PlayerView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.playerView)
    }
}

// MARK: - Preview

#Preview() {
    PlayerView(presenter: .preview())
}
