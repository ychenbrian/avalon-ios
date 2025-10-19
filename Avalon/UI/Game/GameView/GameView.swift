import Observation
import SwiftUI

private enum QuestAvailability { case locked, next, started }

private struct TeamLocator: Identifiable, Equatable {
    let questIndex: Int
    let teamIndex: Int
    var id: String { "\(questIndex)-\(teamIndex)" }
}

struct GameView: View {
    @Environment(GameStore.self) private var store

    @State private var activeAlert: GameViewAlert?
    @State private var newTeam: TeamLocator?
    @State private var isEditingGame = false
    @State private var isGameFinish = false
    @State private var showFinishAlert = false

    private var selectedQuestID: UUID? { store.game.selectedQuestID }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(store.game.quests ?? []) { quest in
                                QuestCircle(quest: quest, isSelected: selectedQuestID == quest.id)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        let status = availability(for: quest)
                                        switch status {
                                        case .locked:
                                            activeAlert = .cannotStart
                                        case .next:
                                            activeAlert = .confirmStart(quest: quest)
                                        case .started:
                                            withAnimation { store.game.selectedQuestID = quest.id }
                                        }
                                    }
                            }
                        }
                    }

                    if let id = selectedQuestID, let quest = store.quest(id: id) {
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
            .padding()
            .navigationTitle(store.game.name.isEmpty == true ? String(localized: "game.untitledGame") : store.game.name ?? "")
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
        .onAppear {
            Task {
                await store.validateGame()
            }
        }
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

            if let quest = store.game.quests.first(where: { $0.index == rIdx }),
               let team = quest.teams.first(where: { $0.teamIndex == tIdx })
            {
                TeamFormSheet(
                    questID: quest.id,
                    teamID: team.id,
                    leader: team.leader,
                    members: team.members,
                    players: store.players,
                    votesByVoter: team.votesByVoter,
                    requiredTeamSize: quest.requiredTeamSize,
                    onSave: { questID, teamID, leader, members, votesByVoter in
                        store.updateTeam(questID: questID, teamID: teamID, leader: leader, members: members, votesByVoter: votesByVoter)
                        withAnimation { newTeam = nil }
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
                gameName: store.game.name,
                numOfPlayers: store.players.count,
                onSave: { numOfPlayers, gameName in
                    withAnimation {
                        isEditingGame = false
                    }
                    if let number = numOfPlayers {
                        store.updateNumOfPlayers(number)
                    }
                    store.updateGameDetails(gameName: gameName)
                },
                onCancel: { withAnimation { isEditingGame = false } },
                onNewGame: {
                    withAnimation {
                        isEditingGame = false
                        store.createNewGame()
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
                    withAnimation {
                        isGameFinish = false
                        store.finishGame(result)
                        showFinishAlert = true
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .alert("gameFinish.title", isPresented: $showFinishAlert) {
            Button("gameFinish.newGame.button", role: .cancel) {
                withAnimation { store.createNewGame() }
            }
            Button("gameFinish.viewGame.button") {
                // TODO: Show the finished game's detail
            }
        } message: {
            Text(getFinishMessage())
        }
    }

    private func availability(for quest: QuestViewData) -> QuestAvailability {
        if quest.index == 0 || quest.status != .notStarted { return .started }
        guard let previousQuest = store.game.quests.first(where: { $0.index == quest.index - 1 }) else {
            return .locked
        }
        if previousQuest.status == .notStarted && quest.status == .notStarted {
            return .locked
        } else {
            return .next
        }
    }

    private func startQuestFlow(from quest: QuestViewData) {
        store.startQuest(quest.index)
        withAnimation { store.game.selectedQuestID = quest.id }

        if quest.teams.first(where: { $0.teamIndex == 0 }) != nil {
            newTeam = TeamLocator(questIndex: quest.index, teamIndex: 0)
        }
    }

    private func getFinishMessage() -> String {
        guard let result = store.game.result else {
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
}
