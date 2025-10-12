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

    @State private var activeAlert: NewQuestAlert?
    @State private var newTeam: TeamLocator?

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
                            "Select a quest",
                            systemImage: "train.side.front.car",
                            description: Text("Tap a circle above.")
                        )
                    }
                }
            }
            .padding()
            .navigationTitle("\(store.game.name) - Quest \((store.quest(id: selectedQuestID ?? UUID())?.index ?? 0) + 1)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeAlert = .confirmNewGame
                    } label: {
                        Label("Add Quest", systemImage: "plus")
                    }
                }
            }
        }
        .alert(item: $activeAlert) { route in
            switch route {
            case .confirmNewGame:
                return Alert(
                    title: Text("Start a new game"),
                    message: Text("Do you want to finish the current one and start a new game?"),
                    primaryButton: .default(Text("Confirm")) {
                        store.initialGame()
                    },
                    secondaryButton: .cancel()
                )
            case .cannotStart:
                return Alert(
                    title: Text("Cannot start this quest"),
                    message: Text("You can’t start this quest yet."),
                    dismissButton: .default(Text("OK"))
                )
            case let .confirmStart(quest):
                return Alert(
                    title: Text("Start new quest?"),
                    message: Text("Do you want to start Quest \(quest.index + 1)?"),
                    primaryButton: .default(Text("Start")) {
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
        .onAppear {
            if selectedQuestID == nil { store.game.selectedQuestID = store.game.quests.first?.id }
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
