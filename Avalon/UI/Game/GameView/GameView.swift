import Combine
import Observation
import SwiftUI

private enum QuestAvailability { case locked, next, started }

private struct TeamLocator: Identifiable, Equatable {
    let questIndex: Int
    let teamIndex: Int
    var id: String { "\(questIndex)-\(teamIndex)" }
}

struct GameView: View {
    @Environment(\.injected) private var injected: DIContainer

    private var gameState: Loadable<Void> { presenter.gameState }
    @State var navigationPath = NavigationPath()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.gameView)
    }

    @Environment(\.modelContext) private var context

    @State private var activeAlert: GameViewAlert?
    @State private var newTeam: TeamLocator?
    @State private var isEditingGame = false
    @State private var isGameFinish = false
    @State private var showFinishAlert = false

    @StateObject private var presenter: GamePresenter

    init(interactor: GamesInteractor) {
        _presenter = StateObject(wrappedValue: GamePresenter(interactor: interactor))
    }

    init(presenter: GamePresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .task { await presenter.loadIfNeeded() }
                .padding()
                .navigationTitle(presenter.game.name.isEmpty == true ? String(localized: "game.untitledGame") : presenter.game.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isEditingGame = true
                        } label: {
                            Label("gameView.toolbar.editGame", systemImage: "pencil")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isGameFinish = true
                        } label: {
                            Label("gameView.toolbar.startAssistanation", systemImage: "drop.fill")
                        }
                    }
                }
        }
        .environmentObject(presenter)
        .alert(item: $activeAlert) { route in
            switch route {
            case .cannotStart:
                return Alert(
                    title: Text("gameView.alert.cannotStart.title"),
                    message: Text("gameView.alert.cannotStart.message"),
                    dismissButton: .default(Text("common.ok"))
                )
            case let .confirmStart(quest):
                let messageFormat = NSLocalizedString("gameView.alert.confirmStart.messageFormat", comment: "Alert message for starting a specific quest")
                let message = String(format: messageFormat, quest.index + 1)

                return Alert(
                    title: Text("gameView.alert.confirmStart.title"),
                    message: Text(message),
                    primaryButton: .default(Text("common.start")) {
                        startQuestFlow(from: quest)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .sheet(item: $newTeam) { key in
            let rIdx = key.questIndex
            let tIdx = key.teamIndex

            if let quest = presenter.game.quests.first(where: { $0.index == rIdx }),
               let team = quest.teams.first(where: { $0.teamIndex == tIdx })
            {
                TeamFormSheet(
                    questID: quest.id,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: presenter.players,
                    votesByVoter: team.votesByVoter,
                    requiredTeamSize: quest.requiredTeamSize,
                    onSave: { questID, teamID, leader, members, votesByVoter in
                        Task { @MainActor in
                            await presenter.updateTeam(questID: questID, teamID: teamID, leader: leader, members: members, votesByVoter: votesByVoter)
                            withAnimation { newTeam = nil }
                        }
                    },
                    onCancel: { withAnimation { newTeam = nil } }
                )
                .presentationDetents([.medium, .large])
            } else {
                Color.clear.onAppear { newTeam = nil }
            }
        }
        .sheet(isPresented: $isEditingGame) {
            GameSettingsFormSheet(
                gameName: presenter.game.name,
                numOfPlayers: presenter.players.count,
                onSave: { numOfPlayers, gameName in
                    Task { @MainActor in
                        withAnimation {
                            isEditingGame = false
                        }
                        if let number = numOfPlayers {
                            await presenter.updateNumOfPlayers(number)
                        }
                        await presenter.updateGameDetails(gameName: gameName)
                    }
                },
                onCancel: { withAnimation { isEditingGame = false } },
                onNewGame: {
                    Task { @MainActor in
                        isEditingGame = false
                        await presenter.createNewGame(resetPlayersToDefault: false)
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isGameFinish) {
            GameFinishFormSheet(
                status: .earlyAssassin,
                result: nil,
                onFinish: { result in
                    Task { @MainActor in
                        isGameFinish = false
                        await presenter.finishGame(result)
                        showFinishAlert = true
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .alert("gameFinish.title", isPresented: $showFinishAlert) {
            Button("gameFinish.newGame.button", role: .cancel) {
                Task { @MainActor in
                    await presenter.createNewGame()
                }
            }
            Button("gameFinish.viewGame.button") {
                // TODO: Show the finished game's detail
            }
        } message: {
            Text(getFinishMessage())
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .flipsForRightToLeftLayoutDirection(true)
    }

    private func availability(for quest: DBModel.Quest) -> QuestAvailability {
        if quest.index == 0 || quest.status != .notStarted { return .started }
        guard let previousQuest = presenter.game.quests.first(where: { $0.index == quest.index - 1 }) else {
            return .locked
        }
        if previousQuest.status == .notStarted && quest.status == .notStarted {
            return .locked
        } else {
            return .next
        }
    }

    private func startQuestFlow(from quest: DBModel.Quest) {
        Task { @MainActor in
            await presenter.startQuest(quest.index)
        }
        withAnimation { presenter.game.selectedQuestID = quest.id }

        if quest.teams.first(where: { $0.teamIndex == 0 }) != nil {
            newTeam = TeamLocator(questIndex: quest.index, teamIndex: 0)
        }
    }

    private func getFinishMessage() -> String {
        guard let result = presenter.game.result else {
            return String(localized: "gameFinish.message.unknown")
        }

        let message: String

        switch result {
        case .goodWinByFailedAss:
            message = String(localized: "gameFinish.message.goodWin")
        case .evilWinByQuest:
            message = String(localized: "gameFinish.message.evilWinQuest")
        case .evilWinByAssassin:
            message = String(localized: "gameFinish.message.evilWinAssassin")
        }

        return "\(message)\n\n\(result.displayText)"
    }

    @ViewBuilder private var content: some View {
        switch gameState {
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

private extension GameView {
    func defaultView() -> some View {
        Text("Default View")
    }

    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {})
    }
}

// MARK: - Displaying Content

@MainActor
private extension GameView {
    func viewDebug() -> Bool {
        return false
    }

    @ViewBuilder
    func loadedView() -> some View {
        if viewDebug() && false {
            EmptyStateView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(presenter.game.sortedQuests) { quest in
                                QuestCircle(quest: quest, isSelected: presenter.selectedQuestID == quest.id)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        let status = availability(for: quest)
                                        switch status {
                                        case .locked:
                                            activeAlert = .cannotStart
                                        case .next:
                                            activeAlert = .confirmStart(quest: quest)
                                        case .started:
                                            withAnimation { presenter.game.selectedQuestID = quest.id }
                                        }
                                    }
                            }
                        }
                    }

                    if let id = presenter.selectedQuestID, let quest = presenter.quest(id: id) {
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
}

// MARK: - Routing

extension GameView {
    struct Routing: Equatable {
        var gameID: UUID?
    }
}

// MARK: - State Updates

private extension GameView {
    private var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.gameView)
    }

    private var canRequestPushPermissionUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: AppState.permissionKeyPath(for: .pushNotifications))
            .map { $0 == .notRequested || $0 == .denied }
            .eraseToAnyPublisher()
    }
}

// MARK: - Preview

#Preview() {
    GameView(presenter: .preview())
}
