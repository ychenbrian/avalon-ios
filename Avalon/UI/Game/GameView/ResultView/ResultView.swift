import SwiftUI

struct ResultView: View {
    @EnvironmentObject var store: GamePresenter
    let questID: UUID

    private var quest: DBModel.Quest? { store.quest(id: questID) }

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("resultView.success.label")
                        .font(.caption)
                        .foregroundColor(.appColor(.primaryTextColor))
                    TextCircle(
                        name: "\((quest?.requiredTeamSize ?? 0) - (quest?.result?.failCount ?? 0))",
                        size: 40,
                        filledColor: .appColor(.successColor)
                    )
                }

                VStack(spacing: 4) {
                    Text("resultView.fail.label")
                        .font(.caption)
                        .foregroundColor(.appColor(.primaryTextColor))
                    TextCircle(
                        name: "\(quest?.result?.failCount ?? 0)",
                        size: 40,
                        filledColor: .appColor(.failColor)
                    )
                }

                if let result = quest?.result?.type, let requiredFail = quest?.requiredFails {
                    VStack(spacing: 4) {
                        Text(String(
                            localized: requiredFail == 1
                                ? "resultView.failRequired.singular.label"
                                : "resultView.failRequired.plural.label"
                        ).replacingOccurrences(of: "%d", with: "\(requiredFail)"))
                            .font(.caption)
                            .foregroundColor(.appColor(.primaryTextColor))

                        TextCapsule(
                            name: result.displayText,
                            height: 40,
                            filledColor: result.color,
                            expandHorizontally: false
                        )
                        .accessibilityLabel(result.accessibilityLabel)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(quest?.result?.type?.color.opacity(0.2) ?? Color(.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let presenter = GamePresenter.preview()
    ResultView(questID: presenter.game.quests.first?.id ?? UUID())
        .environmentObject(presenter)
        .padding()
        .frame(maxWidth: 600)
}
