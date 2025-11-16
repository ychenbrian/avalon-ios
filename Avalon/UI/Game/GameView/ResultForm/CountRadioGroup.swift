import SwiftUI

struct CountRadioGroup: View {
    let teamSize: Int
    let requiredFails: Int
    let selected: (Int) -> Bool
    let action: (Int) -> Void

    init(
        teamSize: Int,
        requiredFails: Int,
        selected: @escaping (Int) -> Bool,
        action: @escaping (Int) -> Void
    ) {
        self.teamSize = teamSize
        self.requiredFails = requiredFails
        self.selected = selected
        self.action = action
    }

    var body: some View {
        HStack {
            ForEach(0 ..< teamSize + 1, id: \.self) { i in
                PlayerCircleToggle(
                    name: "\(i)",
                    isSelected: selected(i),
                    selectedColor: i < requiredFails ? .appColor(.successColor) : .appColor(.failColor)
                ) {
                    action(i)
                }
            }
        }
    }
}

#Preview {
    HStack {
        CountRadioGroup(teamSize: [3, 4, 5].randomElement()!, requiredFails: 2, selected: { _ in [true, false].randomElement() ?? true }, action: { _ in })
    }
}
