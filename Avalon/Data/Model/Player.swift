import SwiftData
import SwiftUI

@Model
final class Player {
    var id: UUID
    var index: Int

    init(id: UUID = UUID(), index: Int) {
        self.id = id
        self.index = index
    }
}
