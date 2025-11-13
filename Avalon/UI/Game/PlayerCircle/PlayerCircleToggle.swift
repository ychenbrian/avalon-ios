import SwiftUI

struct PlayerCircleToggle: View {
    let name: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TextCircle(
                name: String(name.prefix(2)),
                size: 48,
                filledColor: isSelected ? selectedColor : .appColor(.emptyColor)
            )
        }
    }
}

#Preview {
    PlayerCircleToggle(name: "1", isSelected: false, selectedColor: .appColor(.selectedColor), action: {})
}
