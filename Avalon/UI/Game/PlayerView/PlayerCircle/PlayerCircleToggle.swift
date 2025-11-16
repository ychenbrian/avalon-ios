import SwiftUI

struct PlayerCircleToggle: View {
    let name: String
    let isSelected: Bool
    let size: CGFloat
    let selectedColor: Color
    let action: () -> Void

    init(
        name: String,
        isSelected: Bool = false,
        size: CGFloat = 48,
        selectedColor: Color = .appColor(.selectedColor),
        action: @escaping () -> Void = {}
    ) {
        self.name = name
        self.isSelected = isSelected
        self.size = size
        self.selectedColor = selectedColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            TextCircle(
                name: String(name.prefix(2)),
                size: size,
                filledColor: isSelected ? selectedColor : .appColor(.emptyColor)
            )
        }
    }
}

#Preview {
    PlayerCircleToggle(name: "1", isSelected: false, selectedColor: .appColor(.selectedColor), action: {})
}
