import SwiftUI

struct NumberRadioButton: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? selectedColor : Color.gray.opacity(0.5))
                )
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NumberRadioButton(text: "1", isSelected: false, selectedColor: Color.blue, action: {})
}
