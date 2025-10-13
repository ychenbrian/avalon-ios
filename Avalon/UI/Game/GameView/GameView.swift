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

    private var selectedQuestID: UUID? { store.game.selectedQuestID }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(store.game.quests) { quest in
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
            .navigationTitle("\(store.game.name) - Quest \((store.quest(id: selectedQuestID ?? UUID())?.index ?? 0) + 1)")
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

            if store.game.quests.indices.contains(rIdx),
               store.game.quests[rIdx].teams.indices.contains(tIdx)
            {
                let quest = store.game.quests[rIdx]
                let team = quest.teams[tIdx]
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
                numOfPlayers: store.players.count,
                onSave: { numOfPlayers, hasUpdated in
                    withAnimation {
                        isEditingGame = false
                        if hasUpdated {
                            store.updateNumOfPlayers(numOfPlayers)
                        }
                    }
                },
                onCancel: { withAnimation { isEditingGame = false } },
                onNewGame: {
                    withAnimation { isEditingGame = false }
                    store.initialGame()
                }
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            if selectedQuestID == nil { store.game.selectedQuestID = store.game.quests.first?.id }
        }
        .sheet(isPresented: $isGameFinish) {
            GameFinishFormSheet(
                status: .finishWithEarlyAssassin,
                result: nil,
                onFinish: { _ in
                    withAnimation {
                        isGameFinish = false
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func availability(for quest: QuestViewData) -> QuestAvailability {
        if quest.index == 0 || quest.status != .notStarted { return .started }
        let previousQuest = store.game.quests[quest.index - 1]
        if previousQuest.status == .notStarted && quest.status == .notStarted {
            return .locked
        } else {
            return .next
        }
    }

    private func startQuestFlow(from quest: QuestViewData) {
        store.startQuest(quest.index)
        withAnimation { store.game.selectedQuestID = quest.id }

        if quest.teams.first != nil {
            newTeam = TeamLocator(questIndex: quest.index, teamIndex: 0)
        }
    }
}
