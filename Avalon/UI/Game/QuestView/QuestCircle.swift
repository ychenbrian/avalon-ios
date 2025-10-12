import SwiftUI

struct QuestCircle: View {
    @Bindable var quest: QuestViewData
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(getStatusColor())
                    .frame(width: 52, height: 52)
                Text("\(quest.requiredTeamSize)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            Text("\(getStatusText())")
                .font(.caption)
                .bold()
                .foregroundColor(quest.result?.type?.color ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.default, value: quest.teams.count)
    }

    private func getStatusColor() -> Color {
        if quest.status == .finished {
            return quest.result?.type?.color ?? .blue.opacity(0.7)
        } else if quest.status == .inProgress {
            return .blue.opacity(0.7)
        }
        return .gray.opacity(0.5)
    }

    private func getStatusText() -> String {
        if quest.status == .finished {
            guard let result = quest.result else { return "N/A" }

            if result.type == .fail {
                let failVotes = result.failCount ?? 1
                return failVotes == 1 ? "\(failVotes) Fail" : "\(failVotes) Fails"
            } else if result.type == .success {
                return "Success"
            } else {
                return "N/A"
            }
        } else if quest.status == .inProgress {
            return "Progress"
        }
        return "N/A"
    }
}

#Preview {
    HStack {
        ForEach(0 ..< 5) { i in
            let quest = QuestViewData(quest: Quest.random(index: i))
            QuestCircle(quest: quest, isSelected: [true, false].randomElement()!)
        }
    }
}
