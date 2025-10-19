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
    ///   - size: Team size; defaults to a random size within `GameRules.defaultTeamSizeRange`.
    ///   - players: Player pool to draw from.
    static func randomTeam(
        size: Int? = nil,
        from players: [Player] = defaultPlayers()
    ) -> [Player] {
        let teamSize = size ?? Int.random(in: GameRules.defaultTeamSizeRange)
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

// MARK: - AvalonGame

extension AvalonGame {
    static func empty(
        players: [Player] = Player.defaultPlayers(),
        quests: [Quest] = []
    ) -> AvalonGame {
        .init(players: players, quests: quests)
    }

    static func random(players: [Player] = Player.randomTeam()) -> AvalonGame {
        .init(players: players, quests: Quest.randomQuests(for: players))
    }

    static func initial(
        players: [Player] = Player.defaultPlayers(),
        status: GameStatus = .initial
    ) -> AvalonGame {
        let quests = [
            Quest.initial(index: 0, numOfPlayers: players.count, status: .inProgress),
            Quest.initial(index: 1, numOfPlayers: players.count),
            Quest.initial(index: 2, numOfPlayers: players.count),
            Quest.initial(index: 3, numOfPlayers: players.count),
            Quest.initial(index: 4, numOfPlayers: players.count),
        ]
        return .init(players: players, quests: quests, status: status)
    }
}

// MARK: - Team

extension Team {
    static func empty(
        roundIndex: Int,
        teamIndex: Int
    ) -> Team {
        Team(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: .notStarted,
            leaderID: nil,
            memberIDs: [],
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
    ) -> Team {
        let leader = players.randomElement()?.id
        let team = Player.randomTeam(size: teamSize, from: players).map(\.id)

        var votes: [PlayerID: VoteType] = [:]
        for p in players {
            votes[p.id] = Bool.random() ? .approve : .reject
        }

        let teamVoteStatus = status ?? TeamStatus.random()
        let result = result ?? TeamResult.random()

        let teamVote = Team(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: teamVoteStatus,
            leaderID: leader,
            memberIDs: team,
            votesByVoter: votes,
            result: result
        )

        return teamVote
    }

    static func emptyTeams(
        roundIndex: Int,
        totalCount: Int = GameRules.teamsPerQuest
    ) -> [Team] {
        (0 ..< totalCount).map { .empty(roundIndex: roundIndex, teamIndex: $0) }
    }

    static func randomTeams(
        roundIndex: Int,
        finishedIndex: Int = Int.random(in: 0 ... GameRules.teamsPerQuest),
        players: [Player] = Player.defaultPlayers(),
        count: Int = GameRules.teamsPerQuest
    ) -> [Team] {
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

extension Quest {
    static func empty(
        index: Int,
        numOfPlayers: Int,
        status: QuestStatus = .notStarted,
        teams: [Team] = Team.emptyTeams(roundIndex: 0),
        quest: QuestResult? = nil
    ) -> Quest {
        return .init(index: index, numOfPlayers: numOfPlayers, status: status, result: quest, teams: teams)
    }

    static func initial(
        index: Int,
        numOfPlayers: Int,
        status: QuestStatus = .notStarted,
        teams: [Team] = Team.emptyTeams(roundIndex: 0),
        quest: QuestResult? = nil
    ) -> Quest {
        var teams = teams
        if index == 0 {
            if let firstTeam = teams.first {
                firstTeam.status = .inProgress
                teams[0] = firstTeam
            }
        }
        return .init(index: index, numOfPlayers: numOfPlayers, status: status, result: quest, teams: teams)
    }

    static func random(
        index: Int,
        players: [Player] = Player.randomTeam()
    ) -> Quest {
        .init(
            index: index,
            numOfPlayers: players.count,
            status: QuestStatus.random(),
            result: QuestResult.random(),
            teams: Team.randomTeams(roundIndex: index)
        )
    }

    static func randomQuests(
        for players: [Player] = Player.defaultPlayers()
    ) -> [Quest] {
        (0 ..< GameRules.questsPerGame).map { random(index: $0, players: players) }
    }

    static func emptyQuests() -> [Quest] {
        (0 ..< GameRules.questsPerGame).map { .empty(index: $0, numOfPlayers: Int.random(in: 5 ... 10)) }
    }
}

// MARK: - Result

extension QuestResult {
    static func empty(
        type: ResultType = .success,
        failVotes: Int = 0
    ) -> QuestResult {
        .init(type: type, failCount: failVotes)
    }

    static func random() -> QuestResult {
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
