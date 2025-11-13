import SwiftUI

struct GameResultView: View {
    let result: GameResult

    var body: some View {
        Text(result.shortText)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.appColor(.primaryTextColor))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
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
