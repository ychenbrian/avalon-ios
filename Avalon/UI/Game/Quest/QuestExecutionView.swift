import SwiftUI

struct QuestExecutionView: View {
    @State var state: GameQuest
    @State private var showEditSheet = false
    @State private var editState = QuestExecutionEditState(from: GameQuest.empty())

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                VoteCountCircle(
                    count: state.team.count - state.failVotes,
                    color: .green,
                    label: "Success"
                )
                VoteCountCircle(
                    count: state.failVotes,
                    color: .red,
                    label: "Fail"
                )

                let result = state.result
//                ResultCapsule(
//                    displayText: result.displayText,
//                    backgroundColor: result.color,
//                    requiredFail: state.requiredFails,
//                    accessibilityLabel: result.accessibilityLabel
//                )
            }
            .frame(maxWidth: .infinity)

            Button("Edit Quest") {
                editState = QuestExecutionEditState(
                    from: state
                )
                showEditSheet = true
            }
        }
        .padding()
        .sheet(isPresented: $showEditSheet) {
            QuestExecutionEditSheet(
                editState: editState,
                onSave: { editState in
                    editState.apply(to: &state)
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
    QuestExecutionView(state: GameQuest.random())
}
