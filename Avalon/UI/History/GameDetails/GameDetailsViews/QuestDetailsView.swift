import SwiftUI

struct QuestDetailsView: View {
    let quest: DBModel.Quest

    var body: some View {
        VStack {
            HStack {
                Text("Round \(quest.index)")
                    .font(Font.title2.bold())
                    .foregroundColor(.appColor(.primaryTextColor))

                Spacer()

                if quest.result != nil {
                    TextCapsule(
                        name: quest.result?.type?.displayText ?? "Not Finished")
                }
            }
        }
        .padding()
    }
}

#Preview {
    QuestDetailsView(quest: .random(index: 0))
        .background(Color(.systemGroupedBackground))
}
