import SwiftUI

struct GameFinishRadioButton: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TextCapsule(
                name: text,
                height: 48,
                filledColor: isSelected ? selectedColor : .appColor(.emptyColor),
                expandHorizontally: true
            )
        }
    }
}

#Preview {
    GameFinishRadioButton(text: "Finish with 3 Fails", isSelected: false, selectedColor: .appColor(.selectedColor), action: {})
}
