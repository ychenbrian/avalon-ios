import Combine
import Foundation
import SwiftUI

// MARK: - View Inspection helper

final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

// MARK: - Preview helpers

struct PreviewBinding<T, Content: View>: View {
    @State var value: T
    let content: (Binding<T>) -> Content
    init(_ value: T, @ViewBuilder content: @escaping (Binding<T>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View { content($value) }
}

// MARK: - Reference Generator

func generateReference(prefix: String = String(localized: "game.namePrefix")) -> String {
    let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    return "\(prefix) \(String((0 ..< 6).map { _ in chars.randomElement()! }))"
}
