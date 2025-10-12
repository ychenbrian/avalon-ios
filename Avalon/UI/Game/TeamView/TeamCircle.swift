import SwiftUI

struct TeamCircle: View {
    @Bindable var team: TeamViewData
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 52, height: 52)
                Text("\(team.index + 1)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            Text("\(displayText)")
                .font(.caption)
                .bold()
                .foregroundColor(team.result?.color ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
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
        case .notStarted: return "N/A"
        case .inProgress: return "Progress"
        case .finished:
            if let result = team.result {
                return result.displayText
            } else {
                return "Error"
            }
        }
    }
}

#Preview {
    HStack {
        ForEach(0 ..< 5) { i in
            let team = TeamViewData(team: Team.random(roundIndex: 0, teamIndex: i))
            TeamCircle(team: team, isSelected: [true, false].randomElement()!)
        }
    }
}
