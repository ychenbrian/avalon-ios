// MARK: - Player

extension Player {
    /// Default pool of players used by convenience factories.
    static let defaultPlayers: [Player] = (0 ..< GameRules.defaultPlayerCount).map(Player.init(index:))

    /// Returns a random player from the given pool (defaults to `defaultPlayers`).
    static func random(from players: [Player] = defaultPlayers) -> Player {
        players.randomElement() ?? players.first ?? Player(index: 0)
    }

    /// Returns a random team from the given pool.
    /// - Parameters:
    ///   - size: Team size; defaults to a random size within `GameRules.defaultTeamSizeRange`.
    ///   - players: Player pool to draw from.
    static func randomTeam(
        size: Int? = nil,
        from players: [Player] = defaultPlayers
    ) -> [Player] {
        let teamSize = size ?? Int.random(in: GameRules.defaultTeamSizeRange)
        precondition(teamSize >= 0 && teamSize <= players.count, "Invalid team size: \(teamSize)")
        return Array(players.shuffled().prefix(teamSize))
    }

    /// Returns players not in the provided `team`, computed against `players`.
    static func complement(
        of team: [Player],
        in players: [Player] = defaultPlayers
    ) -> [Player] {
        let picked = Set(team.map(\.index))
        return players.filter { !picked.contains($0.index) }
    }

    /// Picks a random team and its complement from the given pool.
    static func randomTeamWithComplement(
        from players: [Player] = defaultPlayers
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
        players: [Player] = Player.defaultPlayers,
        quests: [Quest] = []
    ) -> AvalonGame {
        .init(players: players, quests: quests)
    }

    static func random(players: [Player] = Player.defaultPlayers) -> AvalonGame {
        .init(players: players, quests: Quest.randomQuests(for: players))
    }

    static func initial(
        players: [Player] = Player.defaultPlayers,
        quests: [Quest] = [
            Quest.initial(index: 0, status: .inProgress),
            Quest.initial(index: 1),
            Quest.initial(index: 2),
            Quest.initial(index: 3),
            Quest.initial(index: 4),
        ]
    ) -> AvalonGame {
        .init(players: players, quests: quests)
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
            teamMemberIDs: [],
            votesByVoter: [:],
            result: nil
        )
    }

    static func random(
        roundIndex: Int,
        teamIndex: Int,
        teamSize: Int? = nil,
        players: [Player] = Player.defaultPlayers,
        status: TeamStatus? = nil,
        result: TeamResult? = nil
    ) -> Team {
        let leader = players.randomElement()?.id
        let team = Player.randomTeam(size: teamSize, from: players).map(\.id)

        var votes: [Player: VoteType] = [:]
        for p in players {
            votes[p] = Bool.random() ? .approve : .reject
        }

        let teamVoteStatus = status ?? TeamStatus.random()
        let result = result ?? TeamResult.random()

        let teamVote = Team(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: teamVoteStatus,
            leaderID: leader,
            teamMemberIDs: team,
            votesByVoter: votes,
            result: result
        )

        return teamVote
    }

    static func emptyTeamVotes(
        roundIndex: Int,
        totalCount: Int = GameRules.teamVotesPerRound
    ) -> [Team] {
        (0 ..< totalCount).map { .empty(roundIndex: roundIndex, teamIndex: $0) }
    }

    static func randomTeamVotes(
        roundIndex: Int,
        finishedIndex: Int = Int.random(in: 0 ... GameRules.teamVotesPerRound),
        players: [Player] = Player.defaultPlayers,
        count: Int = GameRules.teamVotesPerRound
    ) -> [Team] {
        (0 ..< count).map {
            if $0 < finishedIndex {
                return .random(roundIndex: roundIndex, teamIndex: $0, players: players, status: .finished, result: .random(isApproved: false))
            } else if $0 == finishedIndex, finishedIndex <= GameRules.teamVotesPerRound - 1 {
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
        status: QuestStatus = .notStarted,
        teamVotes: [Team] = Team.emptyTeamVotes(roundIndex: 0),
        quest: QuestResult? = nil
    ) -> Quest {
        return .init(index: index, status: status, quest: quest, teams: teamVotes)
    }

    static func initial(
        index: Int,
        status: QuestStatus = .notStarted,
        teams: [Team] = Team.emptyTeamVotes(roundIndex: 0),
        quest: QuestResult? = nil
    ) -> Quest {
        var teams = teams
        if index == 0 {
            if var firstTeam = teams.first {
                firstTeam.status = .inProgress
                teams[0] = firstTeam
            }
        }
        return .init(index: index, status: status, quest: quest, teams: teams)
    }

    static func random(
        index: Int,
        players: [Player] = Player.defaultPlayers
    ) -> Quest {
        .init(
            index: index,
            status: QuestStatus.random(),
            quest: QuestResult.random(players: players),
            teams: Team.randomTeamVotes(roundIndex: index)
        )
    }

    static func randomQuests(
        for players: [Player] = Player.defaultPlayers
    ) -> [Quest] {
        (0 ..< GameRules.roundsPerGame).map { random(index: $0, players: players) }
    }

    static func emptyQuests() -> [Quest] {
        (0 ..< GameRules.roundsPerGame).map { .empty(index: $0) }
    }
}

// MARK: - Result

extension QuestResult {
    static func empty(
        leader: Player? = nil,
        team: [Player] = [],
        type: ResultType = .success,
        failVotes: Int = 0
    ) -> QuestResult {
        .init(leader: leader, team: team, type: type, failCount: failVotes)
    }

    static func random(
        players: [Player] = Player.defaultPlayers
    ) -> QuestResult {
        let failVotes = Int.random(in: 0 ... 4)
        return .init(
            leader: Player.random(from: players),
            team: Player.randomTeam(from: players),
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
        players: [Player] = Player.defaultPlayers
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
