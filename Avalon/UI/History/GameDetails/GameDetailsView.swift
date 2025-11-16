import Combine
import SwiftData
import SwiftUI

struct GameDetailsView: View {
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.dismiss) private var dismiss

    @State private var routingState = Routing()
    @StateObject private var presenter: GamePresenter

    private let title: String

    // MARK: - Init

    init(game: DBModel.Game) {
        let presenter = GamePresenter(game: game)
        _presenter = StateObject(wrappedValue: presenter)

        title = game.name.isEmpty
            ? String(localized: "game.untitledGame")
            : game.name
    }

    init(presenter: GamePresenter) {
        _presenter = StateObject(wrappedValue: presenter)

        title = presenter.game.name.isEmpty
            ? String(localized: "game.untitledGame")
            : presenter.game.name
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(.horizontal)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(presenter)
            .toolbar(.hidden, for: .tabBar)
            .onReceive(routingUpdate) { routingState = $0 }
            .toolbar {
                if presenter.game.status != .complete {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            backToGameTab()
                        } label: {
                            Text("gameDetails.edit.button")
                        }
                    }
                }
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

    private func backToGameTab() {
        dismiss()

        injected.appState.bulkUpdate { state in
            state.routing.gameDetailsView.gameID = nil
            state.routing.gameView.gameID = presenter.game.id
            state.routing.selectedTab = .game
        }
    }
}

// MARK: - Displaying Content

private extension GameDetailsView {
    @ViewBuilder
    var loadedView: some View {
        if presenter.game.status == .initial {
            EmptyStateView()
        } else {
            GameContentView(activeAlert: .constant(nil))
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

extension GameDetailsView {
    struct Routing: Equatable {
        var gameID: UUID?
    }
}

// MARK: - State Updates

private extension GameDetailsView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.gameDetailsView)
    }
}
