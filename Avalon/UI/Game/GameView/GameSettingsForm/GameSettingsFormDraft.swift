import SwiftUI

struct GameSettingsFormDraft: Equatable {
    var gameName: String
    let numOfPlayers: Int
    var updatedNumber: Int

    var hasNumOfPlayersUpdate: Bool {
        numOfPlayers != updatedNumber
    }

    mutating func setNumberOfPlayers(_ number: Int) {
        guard GameRules.numOfPlayerRange.contains(number) else { return }
        updatedNumber = number
    }

    mutating func resetNumberOfPlayers() {
        updatedNumber = numOfPlayers
    }

    mutating func updateGameName(_ name: String) {
        gameName = name
    }
}
