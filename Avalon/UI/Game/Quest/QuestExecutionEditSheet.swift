import SwiftUI

struct QuestExecutionEditSheet: View {
    @State var editState: QuestExecutionEditState
    let onSave: (QuestExecutionEditState) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Select Team")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                PlayerGrid(
                    players: Array(editState.team),
                    selected: { editState.team.contains($0) },
                    action: { toggleTeamMember($0) }
                )
                .padding(.vertical, 12)

                Text("Select Number of Failed Quests")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)

                FailedQuestGrid(
                    selected: { editState.failVotes == $0 },
                    action: { number in
                        editState.failVotes = number
                    }
                )
                .padding(.vertical, 12)
            }
            .padding(.horizontal)
            .navigationTitle("Edit Quest Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Cancel editing quest result")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: {
                        onSave(editState)
                    })
                    .accessibilityLabel("Save quest result")
                }
            }
            .interactiveDismissDisabled(false)
        }
    }

    private func toggleTeamMember(_ player: Player) {
        if editState.team.contains(player) {
            editState.team.remove(player)
        } else {
            editState.team.insert(player)
        }
    }
}

struct QuestExecutionEditSheetPreview: View {
    @State var editState = QuestExecutionEditState(from: GameQuest.random())

    var body: some View {
        QuestExecutionEditSheet(
            editState: editState,
            onSave: { _ in },
            onCancel: {}
        )
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    QuestExecutionEditSheetPreview()
}
