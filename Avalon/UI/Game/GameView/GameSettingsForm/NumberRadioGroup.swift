import SwiftUI

struct NumberRadioGroup: View {
    let range: Range<Int>
    let selected: (Int) -> Bool
    let action: (Int) -> Void

    init(
        range: Range<Int>,
        selected: @escaping (Int) -> Bool,
        action: @escaping (Int) -> Void
    ) {
        self.range = range
        self.selected = selected
        self.action = action
    }

    var body: some View {
        HStack {
            ForEach(range, id: \.self) { i in
                TextRadioButton(
                    text: "\(i)",
                    isSelected: selected(i),
                    selectedColor: .appColor(.selectedColor)
                ) {
                    action(i)
                }
            }
        }
    }
}

#Preview {
    HStack {
        NumberRadioGroup(range: 5 ..< 11, selected: { _ in [true, false].randomElement() ?? true }, action: { _ in })
    }
}
