import SwiftUI

struct TextRadioButton: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TextCircle(
                name: text,
                size: 48,
                filledColor: isSelected ? selectedColor : .appColor(.emptyColor)
            )
        }
    }
}

#Preview {
    TextRadioButton(text: "1", isSelected: false, selectedColor: .appColor(.selectedColor), action: {})
}
