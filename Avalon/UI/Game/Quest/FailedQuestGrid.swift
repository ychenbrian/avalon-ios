import SwiftUI

struct FailedQuestGrid: View {
    let selected: (Int) -> Bool
    let action: (Int) -> Void

    var body: some View {
        HStack {
            ForEach(0 ..< 5) { number in
                FailedQuestToggle(
                    number: number,
                    isSelected: selected(number)
                ) {
                    action(number)
                }
            }
        }
    }
}

#Preview {
    FailedQuestGrid(
        selected: { _ in
            true
        },
        action: { _ in
        }
    )
}
