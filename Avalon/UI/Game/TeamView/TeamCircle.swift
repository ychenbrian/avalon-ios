import SwiftUI

struct TeamCircle: View {
    @Bindable var team: DBModel.Team
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            TextCircle(
                name: "\(team.teamIndex + 1)",
                size: 52,
                filledColor: fillColor
            )
            Text(displayText)
                .font(.caption)
                .bold()
                .foregroundColor(team.result?.textColor ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? .appColor(.selectedColor).opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var fillColor: Color {
        switch team.status {
        case .notStarted: return .appColor(.emptyColor)
        case .inProgress: return .appColor(.selectedColor)
        case .finished:
            if let result = team.result {
                return result.isApproved ? .appColor(.successColor) : .appColor(.failColor)
            } else {
                return .appColor(.emptyColor)
            }
        }
    }

    private var displayText: String {
        switch team.status {
        case .notStarted: return String(localized: "common.na")
        case .inProgress: return String(localized: "quest.status.inProgress")
        case .finished:
            if let result = team.result {
                return result.displayText
            } else {
                return String(localized: "common.na")
            }
        }
    }
}

#Preview {
    HStack {
        ForEach(0 ..< 5) { i in
            let team = DBModel.Team.random(roundIndex: 0, teamIndex: i)
            TeamCircle(team: team, isSelected: [true, false].randomElement()!)
        }
    }
}
