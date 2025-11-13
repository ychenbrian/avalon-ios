import SwiftUI

struct QuestCircle: View {
    @Bindable var quest: DBModel.Quest
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            TextCircle(
                name: "\(quest.requiredTeamSize)",
                size: 52,
                filledColor: getStatusColor()
            )
            Text(getStatusText())
                .font(.caption)
                .bold()
                .foregroundColor(quest.result?.type?.textColor ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? .appColor(.selectedColor).opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.default, value: quest.teams.count)
    }

    private func getStatusColor() -> Color {
        if quest.status == .finished {
            return quest.result?.type?.color ?? .appColor(.selectedColor)
        } else if quest.status == .inProgress {
            return .appColor(.selectedColor)
        }
        return .appColor(.emptyColor)
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
            let quest = DBModel.Quest.random(index: i)
            QuestCircle(quest: quest, isSelected: [true, false].randomElement()!)
        }
    }
}
