import SwiftUI

struct GameFormDraft: Equatable {
    var numOfPlayers: Int

    mutating func setNumberOfPlayers(_ number: Int) {
        numOfPlayers = number
    }
}
