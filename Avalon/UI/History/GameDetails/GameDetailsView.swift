import Combine
import SwiftData
import SwiftUI

struct GameDetailsView: View {
    @Environment(\.injected) private var injected: DIContainer

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
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(presenter)
            .onReceive(routingUpdate) { routingState = $0 }
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
}

// MARK: - Displaying Content

private extension GameDetailsView {
    @ViewBuilder
    var loadedView: some View {
        if presenter.game.status == .initial {
            EmptyStateView()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(presenter.game.sortedQuests) { quest in
                                QuestCircle(
                                    quest: quest,
                                    isSelected: presenter.selectedQuestID == quest.id
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        presenter.game.selectedQuestID = quest.id
                                    }
                                }
                            }
                        }
                    }

                    if let id = presenter.selectedQuestID,
                       let quest = presenter.quest(id: id)
                    {
                        QuestDetailView(questID: quest.id)
                    } else {
                        ContentUnavailableView(
                            "gameView.unavailable.title",
                            systemImage: "train.side.front.car",
                            description: Text("gameView.unavailable.description")
                        )
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

extension GameDetailsView {
    struct Routing: Equatable {}
}

// MARK: - State Updates

private extension GameDetailsView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.gameDetailsView)
    }
}
