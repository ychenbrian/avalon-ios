import SwiftUI

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    let index: Int

    init(index: Int) {
        id = UUID()
        self.index = index
    }
}
