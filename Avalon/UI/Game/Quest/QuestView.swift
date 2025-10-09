import SwiftUI

struct QuestView: View {
    @State var viewModel: QuestViewModel
    @State private var showEditSheet = false
    @State private var editState = QuestExecutionEditState(from: GameQuest.empty())

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                VoteCountCircle(
                    count: viewModel.quest.team.count - viewModel.quest.failVotes,
                    color: .green,
                    label: "Success"
                )
                VoteCountCircle(
                    count: viewModel.quest.failVotes,
                    color: .red,
                    label: "Fail"
                )

                if let result = viewModel.quest.result {
                    ResultCapsule(
                        displayText: result.displayText,
                        backgroundColor: result.color,
                        requiredFail: viewModel.requiredFail,
                        accessibilityLabel: result.accessibilityLabel
                    )
                }
            }
            .frame(maxWidth: .infinity)

            Button("Edit Quest") {
                editState = QuestExecutionEditState(
                    from: viewModel.quest
                )
                showEditSheet = true
            }
        }
        .padding()
        .sheet(isPresented: $showEditSheet) {
            QuestExecutionEditSheet(
                editState: editState,
                onSave: { _ in
//                    editState.apply(to: &viewModel.quest)
                    showEditSheet = false
                },
                onCancel: {
                    showEditSheet = false
                }
            )
        }
    }
}

#Preview {
    QuestView(viewModel: QuestViewModel(quest: GameQuest.random(), requiredFail: 5))
        .environment(Players.preview)
}
