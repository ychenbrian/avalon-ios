import SwiftUI

// MARK: - Game Rules

class GameRules {
    static let defaultPlayerCount: Int = 10
    static let questsPerGame: Int = 5
    static let teamsPerQuest: Int = 5
    static let numOfPlayerRange: Range<Int> = 5 ..< 11
    static let teamSizeRange: Range<Int> = 2 ..< 6

    static func getRequiredTeamSize(numOfPlayers: Int, questIndex: Int) -> Int {
        guard (0 ..< 5).contains(questIndex) else { return 0 }

        var teamSizeList: [Int] = []
        switch numOfPlayers {
        case 5: teamSizeList = [2, 3, 2, 3, 3]
        case 6: teamSizeList = [2, 3, 4, 3, 4]
        case 7: teamSizeList = [2, 3, 3, 4, 4]
        case 8 ... 10: fallthrough
        default: teamSizeList = [3, 4, 4, 5, 5]
        }
        return teamSizeList[questIndex]
    }

    static func getRequiredFails(numOfPlayers: Int, questIndex: Int) -> Int {
        if numOfPlayers >= 7 {
            return questIndex == 3 ? 2 : 1
        } else {
            return 1
        }
    }
}
