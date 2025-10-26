import Foundation
import SwiftData
import SwiftUI

@Observable
final class GameGroupViewData {
    let games: [DBModel.Game]
    let date: String

    init(games: [DBModel.Game], date: String) {
        self.games = games
        self.date = date
    }
}
