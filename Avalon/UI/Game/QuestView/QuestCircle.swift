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
            Text(getStatusText())
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
            guard let result = quest.result else { return String(localized: "common.na") }

            if result.type == .fail {
                let failVotes = result.failCount
                if failVotes == 1 {
                    return String(localized: "quest.result.fail.singular")
                        .replacingOccurrences(of: "%d", with: "\(failVotes)")
                } else {
                    return String(localized: "quest.result.fail.plural")
                        .replacingOccurrences(of: "%d", with: "\(failVotes)")
                }
            } else if result.type == .success {
                return String(localized: "quest.result.success")
            } else {
                return String(localized: "common.na")
            }
        } else if quest.status == .inProgress {
            return String(localized: "quest.status.inProgress")
        }
        return String(localized: "common.na")
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
