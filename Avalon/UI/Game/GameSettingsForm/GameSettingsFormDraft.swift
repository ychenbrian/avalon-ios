import SwiftUI

struct GameSettingsFormDraft: Equatable {
    var numOfPlayers: Int

    mutating func setNumberOfPlayers(_ number: Int) {
        numOfPlayers = number
    }
}
