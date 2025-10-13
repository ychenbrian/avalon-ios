import SwiftUI

struct GameSettingsFormDraft: Equatable {
    let numOfPlayers: Int
    var updatedNumber: Int
    var hasUpdated: Bool = false

    mutating func setNumberOfPlayers(_ number: Int) {
        if numOfPlayers != number {
            hasUpdated = true
        } else {
            hasUpdated = false
        }

        updatedNumber = number
    }
}
