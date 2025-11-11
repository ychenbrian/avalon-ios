import Combine
import SwiftData
import SwiftUI

struct GameDetails: View {
    private let game: DBModel.Game

    @Environment(\.locale) var locale: Locale
    @Environment(\.injected) private var injected: DIContainer
    @State private var details: Loadable<DBModel.Game>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.gameDetails)
    }

    let inspection = Inspection<Self>()

    init(game: DBModel.Game, details: Loadable<DBModel.Game> = .notRequested) {
        self.game = game
        _details = .init(initialValue: details)
    }

    var body: some View {
        content
            .navigationBarTitle(game.name.isEmpty ? String(localized: "game.untitledGame") : game.name)
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }

    @ViewBuilder private var content: some View {
        switch details {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case let .loaded(details):
            loadedView(details)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Displaying Content

@MainActor
private extension GameDetails {
    func loadedView(_ game: DBModel.Game) -> some View {
        List {
            Text(game.result?.displayText ?? "-")
        }
        .listStyle(GroupedListStyle())
    }
}

// MARK: - Loading Content

private extension GameDetails {
    func defaultView() -> some View {
        Text("").onAppear {
            loadGameDetails(forceReload: false)
        }
    }

    func loadingView() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Button(action: {
                self.details.cancelLoading()
            }, label: { Text("Cancel loading") })
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadGameDetails(forceReload: true)
        })
    }
}

// MARK: - Side Effects

private extension GameDetails {
    func loadGameDetails(forceReload _: Bool) {
        $details.load {
            try await injected.interactors.games
                .getGame(game) ?? DBModel.Game.initial()
        }
    }

    func showGameDetailsSheet() {
        injected.appState[\.routing.gameDetails.detailsSheet] = true
    }
}

// MARK: - Routing

extension GameDetails {
    struct Routing: Equatable {
        var detailsSheet: Bool = false
    }
}

// MARK: - State Updates

private extension GameDetails {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.gameDetails)
    }
}
