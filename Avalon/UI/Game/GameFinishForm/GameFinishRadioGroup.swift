import SwiftUI

struct GameFinishRadioGroup: View {
    let texts: [String]
    let selected: (String) -> Bool
    let action: (String) -> Void

    init(
        texts: [String],
        selected: @escaping (String) -> Bool,
        action: @escaping (String) -> Void
    ) {
        self.texts = texts
        self.selected = selected
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(texts, id: \.self) { text in
                GameFinishRadioButton(
                    text: text,
                    isSelected: selected(text),
                    selectedColor: .blue
                ) {
                    action(text)
                }
            }
        }
    }
}

#Preview {
    HStack {
        GameFinishRadioGroup(texts: ["Text 1", "Text 2"], selected: { _ in [true, false].randomElement() ?? true }, action: { _ in })
    }
}
