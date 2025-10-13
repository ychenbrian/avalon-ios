import SwiftUI

struct GameFinishRadioButton: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, 16)
                .foregroundColor(.white)
                .background(
                    Capsule()
                        .fill(isSelected ? selectedColor : Color.gray.opacity(0.5))
                )
        }
    }
}

#Preview {
    GameFinishRadioButton(text: "Finish with 3 Fails", isSelected: false, selectedColor: Color.blue, action: {})
}
