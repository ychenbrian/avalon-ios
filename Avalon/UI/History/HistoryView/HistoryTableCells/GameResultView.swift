import SwiftUI

struct GameResultView: View {
    let result: GameResult

    var body: some View {
        Text(result.shortText)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(result.color)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        GameResultView(result: .goodWinByFailedAss)
        GameResultView(result: .evilWinByQuest)
        GameResultView(result: .evilWinByAssassin)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
