import SwiftData
import SwiftUI

public typealias PlayerID = UUID

@Model
final class Player {
    var id: PlayerID
    var index: Int

    init(id: PlayerID = PlayerID(), index: Int) {
        self.id = id
        self.index = index
    }
}
