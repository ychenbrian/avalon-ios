import SwiftUI

private enum QuestAvailability { case locked, next, started }

struct GameContentView: View {
    @EnvironmentObject var presenter: GamePresenter
    @Binding var activeAlert: GameViewAlert?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    if !presenter.allowEditing, let text = presenter.game.resultText {
                        Text(text)
                            .padding()
                    }

                    HStack {
                        ForEach(Array(presenter.game.sortedQuests.enumerated()), id: \.element.id) { index, quest in
                            QuestCircle(quest: quest, isSelected: presenter.selectedQuestID == quest.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onTapQuest(quest: quest)
                                }
                            if index < presenter.game.sortedQuests.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
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

    // MARK: - Action

    private func onTapQuest(quest: DBModel.Quest) {
        if presenter.allowEditing {
            let status = availability(for: quest)
            switch status {
            case .locked:
                activeAlert = .cannotStart
            case .next:
                activeAlert = .confirmStart(quest: quest)
            case .started:
                withAnimation {
                    presenter.game.selectedQuestID = quest.id
                }
            }
        } else {
            withAnimation {
                presenter.game.selectedQuestID = quest.id
            }
        }
    }

    // MARK: - Helper

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
}
