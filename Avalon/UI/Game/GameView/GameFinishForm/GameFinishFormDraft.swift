import SwiftUI

struct GameFinishFormDraft: Equatable {
    var status: GameStatus
    var result: GameResult?

    mutating func setGameResult(_ result: GameResult) {
        self.result = result
    }
}
