import SwiftUI

struct RoundCircle: View {
    @Bindable var round: RoundViewData
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(getStatusColor())
                    .frame(width: 52, height: 52)
                Text("\(round.requiredTeamSize)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            Text("\(getStatusText())")
                .font(.caption)
                .bold()
                .foregroundColor(round.result?.color ?? .secondary)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.default, value: round.teams.count)
    }

    private func getStatusColor() -> Color {
        if round.status == .finished {
            return round.status.color
        } else if round.status == .inProgress {
            return .blue.opacity(0.7)
        }
        return .gray.opacity(0.5)
    }

    private func getStatusText() -> String {
        if round.status == .finished {
            return round.result?.displayText ?? "N/A"
        } else if round.status == .inProgress {
            return "Progress"
        }
        return "N/A"
    }
}

#Preview("Round – circle") {
    HStack {
        ForEach(0 ..< 5) { i in
            let round = RoundViewData(round: GameRound.random(index: i))
            RoundCircle(round: round, isSelected: [true, false].randomElement()!)
        }
    }
}
