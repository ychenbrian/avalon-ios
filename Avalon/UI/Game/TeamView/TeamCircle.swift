import SwiftUI

struct TeamCircle: View {
    @Bindable var team: DBModel.Team
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 52, height: 52)
                Text("\(team.teamIndex + 1)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            Text(displayText)
                .font(.caption)
                .bold()
                .foregroundColor(team.result?.color ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var fillColor: Color {
        switch team.status {
        case .notStarted: return .gray.opacity(0.5)
        case .inProgress: return .blue.opacity(0.7)
        case .finished:
            if let result = team.result {
                return result.isApproved ? .green.opacity(0.8) : .red.opacity(0.8)
            } else {
                return .gray.opacity(0.3)
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
