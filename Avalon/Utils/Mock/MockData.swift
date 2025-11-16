// MARK: - Player

extension Player {
    /// Default pool of players used by convenience factories.
    static func defaultPlayers(size: Int = GameRules.defaultPlayerCount) -> [Player] {
        return (0 ..< size).map { Player(index: $0) }
    }

    /// Returns a random player from the given pool (defaults to `defaultPlayers`).
    static func random(from players: [Player] = defaultPlayers()) -> Player {
        players.randomElement() ?? players.first ?? Player(index: 0)
    }

    /// Returns a random team from the given pool.
    /// - Parameters:
    ///   - size: Team size; defaults to a random size within `GameRules.teamSizeRange`.
    ///   - players: Player pool to draw from.
    static func randomTeam(
        size: Int? = nil,
        from players: [Player] = defaultPlayers()
    ) -> [Player] {
        let teamSize = size ?? Int.random(in: GameRules.teamSizeRange)
        precondition(teamSize >= 0 && teamSize <= players.count, "Invalid team size: \(teamSize)")
        return Array(players.shuffled().prefix(teamSize))
    }

    /// Returns players not in the provided `team`, computed against `players`.
    static func complement(
        of team: [Player],
        in players: [Player] = defaultPlayers()
    ) -> [Player] {
        let picked = Set(team.map(\.index))
        return players.filter { !picked.contains($0.index) }
    }

    /// Picks a random team and its complement from the given pool.
    static func randomTeamWithComplement(
        from players: [Player] = defaultPlayers()
    ) -> (team: [Player], complement: [Player]) {
        let size = Int.random(in: 0 ... players.count)
        let team = randomTeam(size: size, from: players)
        let comp = complement(of: team, in: players)
        return (team, comp)
    }
}

// MARK: - Game

extension DBModel.Game {
    static func empty(
        startedAt: String? = nil,
        finishedAt: String? = nil,
        players: [Player] = Player.defaultPlayers(),
        quests: [DBModel.Quest] = [],
        result: GameResult? = nil,
        status: GameStatus? = nil
    ) -> DBModel.Game {
        .init(startedAt: startedAt, finishedAt: finishedAt, players: players, quests: quests, status: status, result: result)
    }

    static func random(
        players: [Player] = Player.randomTeam(),
        status: GameStatus = .random()
    ) -> DBModel.Game {
        .init(
            players: players,
            quests: DBModel.Quest.randomQuests(for: players),
            status: status
        )
    }

    static func initial(
        players: [Player] = Player.defaultPlayers(),
        status: GameStatus = .initial
    ) -> DBModel.Game {
        let quests = [
            DBModel.Quest.initial(index: 0, numOfPlayers: players.count, status: .inProgress),
            DBModel.Quest.initial(index: 1, numOfPlayers: players.count),
            DBModel.Quest.initial(index: 2, numOfPlayers: players.count),
            DBModel.Quest.initial(index: 3, numOfPlayers: players.count),
            DBModel.Quest.initial(index: 4, numOfPlayers: players.count),
        ]
        return .init(players: players, quests: quests, status: status)
    }
}

// MARK: - Team

extension DBModel.Team {
    static func empty(
        roundIndex: Int,
        teamIndex: Int
    ) -> DBModel.Team {
        DBModel.Team(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: .notStarted,
            leader: nil,
            members: [],
            votesByVoter: [:],
            result: nil
        )
    }

    static func random(
        roundIndex: Int,
        teamIndex: Int,
        teamSize: Int? = nil,
        players: [Player] = Player.defaultPlayers(),
        status: TeamStatus? = nil,
        result: TeamResult? = nil
    ) -> DBModel.Team {
        let leader = players.randomElement()
        let members = Player.randomTeam(size: teamSize, from: players)

        var votes: [PlayerID: VoteType] = [:]
        for player in players {
            votes[player.id] = Bool.random() ? .approve : .reject
        }

        let teamVoteStatus = status ?? TeamStatus.random()
        let result = result ?? TeamResult.random()

        let teamVote = DBModel.Team(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: teamVoteStatus,
            leader: leader,
            members: members,
            votesByVoter: votes,
            result: result
        )

        return teamVote
    }

    static func emptyTeams(
        roundIndex: Int,
        totalCount: Int = GameRules.teamsPerQuest
    ) -> [DBModel.Team] {
        (0 ..< totalCount).map { .empty(roundIndex: roundIndex, teamIndex: $0) }
    }

    static func randomTeams(
        roundIndex: Int,
        finishedIndex: Int = Int.random(in: 0 ... GameRules.teamsPerQuest),
        players: [Player] = Player.defaultPlayers(),
        count: Int = GameRules.teamsPerQuest
    ) -> [DBModel.Team] {
        (0 ..< count).map {
            if $0 < finishedIndex {
                return .random(roundIndex: roundIndex, teamIndex: $0, players: players, status: .finished, result: .random(isApproved: false))
            } else if $0 == finishedIndex, finishedIndex <= GameRules.teamsPerQuest - 1 {
                return .random(roundIndex: roundIndex, teamIndex: $0, players: players)
            }
            return .random(roundIndex: roundIndex, teamIndex: $0, players: players, status: .notStarted)
        }
    }
}

// MARK: - Quest

extension DBModel.Quest {
    static func empty(
        index: Int,
        numOfPlayers: Int,
        status: QuestStatus = .notStarted,
        teams: [DBModel.Team] = DBModel.Team.emptyTeams(roundIndex: 0),
        result: DBModel.QuestResult? = nil
    ) -> DBModel.Quest {
        return .init(index: index, numOfPlayers: numOfPlayers, status: status, result: result, teams: teams)
    }

    static func initial(
        index: Int,
        numOfPlayers: Int,
        status: QuestStatus = .notStarted,
        teams: [DBModel.Team] = DBModel.Team.emptyTeams(roundIndex: 0),
        result: DBModel.QuestResult? = nil
    ) -> DBModel.Quest {
        var teams = teams
        if index == 0 {
            if let firstTeam = teams.first {
                firstTeam.status = .inProgress
                teams[0] = firstTeam
            }
        }
        return .init(index: index, numOfPlayers: numOfPlayers, status: status, result: result, teams: teams)
    }

    static func random(
        index: Int,
        players: [Player] = Player.randomTeam()
    ) -> DBModel.Quest {
        .init(
            index: index,
            numOfPlayers: players.count,
            status: QuestStatus.random(),
            result: DBModel.QuestResult.random(),
            teams: DBModel.Team.randomTeams(roundIndex: index)
        )
    }

    static func randomQuests(
        for players: [Player] = Player.defaultPlayers()
    ) -> [DBModel.Quest] {
        (0 ..< GameRules.questsPerGame).map { random(index: $0, players: players) }
    }

    static func emptyQuests() -> [DBModel.Quest] {
        (0 ..< GameRules.questsPerGame).map { .empty(index: $0, numOfPlayers: Int.random(in: 5 ... 10)) }
    }
}

// MARK: - QuestResult

extension DBModel.QuestResult {
    static func empty(
        type: ResultType = .success,
        failVotes: Int = 0
    ) -> DBModel.QuestResult {
        .init(type: type, failCount: failVotes)
    }

    static func random() -> DBModel.QuestResult {
        let failVotes = Int.random(in: 0 ... 4)
        return .init(
            type: ResultType.random(),
            failCount: failVotes
        )
    }
}

// MARK: - Random helpers for enums

extension QuestStatus {
    static func random() -> QuestStatus {
        let options: [QuestStatus] = [.notStarted, .inProgress, .finished]
        return options.randomElement() ?? .notStarted
    }
}

extension GameStatus {
    static func random() -> GameStatus {
        let options: [GameStatus] = [.initial, .inProgress, .complete, .earlyAssassin, .threeFails, .threeSuccesses]
        return options.randomElement() ?? .inProgress
    }
}

extension TeamStatus {
    static func random() -> TeamStatus {
        let options: [TeamStatus] = [.notStarted, .inProgress, .finished]
        return options.randomElement() ?? .notStarted
    }
}

extension TeamResult {
    static func random(
        isApproved: Bool? = nil,
        players: [Player] = Player.defaultPlayers()
    ) -> TeamResult {
        let total = players.count
        let approvedCount: Int

        if let forcedApproval = isApproved {
            if forcedApproval {
                approvedCount = Int.random(in: (total / 2 + 1) ... total)
            } else {
                approvedCount = Int.random(in: 0 ... (total / 2 - 1))
            }
        } else {
            approvedCount = Int.random(in: 0 ... total)
        }

        let rejectedCount = total - approvedCount

        return .init(
            isApproved: approvedCount > rejectedCount,
            approvedCount: approvedCount,
            rejectedCount: rejectedCount
        )
    }
}

extension ResultType {
    static func random() -> ResultType {
        let options: [ResultType] = [.success, .fail]
        return options.randomElement() ?? .success
    }
}
