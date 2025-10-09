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
        rounds: [GameRound] = []
    ) -> AvalonGame {
        .init(players: players, rounds: rounds)
    }

    static func random(players: [Player] = Player.defaultPlayers) -> AvalonGame {
        .init(players: players, rounds: GameRound.randomRounds(for: players))
    }

    static func initial(
        players: [Player] = Player.defaultPlayers,
        rounds: [GameRound] = [
            GameRound.empty(index: 0, status: .inProgress),
            GameRound.empty(index: 1),
            GameRound.empty(index: 2),
            GameRound.empty(index: 3),
            GameRound.empty(index: 4),
        ]
    ) -> AvalonGame {
        .init(players: players, rounds: rounds)
    }
}

// MARK: - TeamVote

extension TeamVote {
    static func empty(
        roundIndex: Int,
        teamIndex: Int
    ) -> TeamVote {
        TeamVote(
            roundIndex: roundIndex,
            teamIndex: teamIndex,
            status: .notStarted,
            leaderID: nil,
            teamMemberIDs: [],
            votesByVoter: [:],
            result: nil
        )
    }

    /// Create a single random team for a given index.
    static func random(
        roundIndex: Int,
        teamIndex: Int,
        teamSize: Int? = nil,
        players: [Player] = Player.defaultPlayers,
        status: TeamVoteStatus? = nil,
        result: TeamVoteResult? = nil
    ) -> TeamVote {
        let leader = players.randomElement()?.id
        let team = Player.randomTeam(size: teamSize, from: players).map(\.id)

        // Generate random votes
        var votes: [Player: VoteType] = [:]
        for p in players {
            votes[p] = Bool.random() ? .approve : .reject
        }

        let teamVoteStatus = status ?? TeamVoteStatus.random()
        let result = result ?? TeamVoteResult.random()

        let teamVote = TeamVote(
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

    /// Helper to build empty team votes with incrementing indices.
    static func emptyTeamVotes(
        roundIndex: Int,
        totalCount: Int = GameRules.teamVotesPerRound
    ) -> [TeamVote] {
        (0 ..< totalCount).map { .empty(roundIndex: roundIndex, teamIndex: $0) }
    }

    /// Create up to `count` random team votes and pad to full round length with empties.
    static func randomTeamVotes(
        roundIndex: Int,
        finishedIndex: Int = Int.random(in: 0 ... GameRules.teamVotesPerRound),
        players: [Player] = Player.defaultPlayers,
        count: Int = GameRules.teamVotesPerRound
    ) -> [TeamVote] {
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

// MARK: - GameRound

extension GameRound {
    static func empty(
        index: Int,
        status: RoundStatus = .notStarted,
        teamVotes: [TeamVote] = TeamVote.emptyTeamVotes(roundIndex: 0),
        quest: GameQuest? = nil
    ) -> GameRound {
        var teamVotes = teamVotes
        if var firstVote = teamVotes.first {
            firstVote.status = .inProgress
            teamVotes[0] = firstVote
        }
        return .init(index: index, status: status, quest: quest, teamVotes: teamVotes)
    }

    /// A single random round.
    static func random(
        index: Int,
        players: [Player] = Player.defaultPlayers
    ) -> GameRound {
        .init(
            index: index,
            status: RoundStatus.random(),
            quest: GameQuest.random(players: players),
            teamVotes: TeamVote.randomTeamVotes(roundIndex: index)
        )
    }

    /// Exactly `GameRules.roundsPerGame` rounds.
    static func randomRounds(
        for players: [Player] = Player.defaultPlayers
    ) -> [GameRound] {
        (0 ..< GameRules.roundsPerGame).map { random(index: $0, players: players) }
    }

    /// Convenience: a full set of empty rounds.
    static func emptyRounds() -> [GameRound] {
        (0 ..< GameRules.roundsPerGame).map { .empty(index: $0) }
    }
}

// MARK: - GameQuest

extension GameQuest {
    static func empty(
        leader: Player? = nil,
        team: [Player] = [],
        result: QuestResult = .success,
        failVotes: Int = 0
    ) -> GameQuest {
        .init(leader: leader, team: team, result: result, failVotes: failVotes)
    }

    static func random(
        players: [Player] = Player.defaultPlayers
    ) -> GameQuest {
        let failVotes = Int.random(in: 0 ... 4)
        return .init(
            leader: Player.random(from: players),
            team: Player.randomTeam(from: players),
            result: QuestResult.random(),
            failVotes: failVotes
        )
    }
}

// MARK: - Random helpers for enums

extension RoundStatus {
    static func random() -> RoundStatus {
        let options: [RoundStatus] = [.notStarted, .inProgress, .finished]
        return options.randomElement() ?? .notStarted
    }
}

extension TeamVoteStatus {
    static func random() -> TeamVoteStatus {
        let options: [TeamVoteStatus] = [.notStarted, .inProgress, .finished]
        return options.randomElement() ?? .notStarted
    }
}

extension TeamVoteResult {
    static func random(
        isApproved: Bool? = nil,
        players: [Player] = Player.defaultPlayers
    ) -> TeamVoteResult {
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

extension QuestResult {
    static func random() -> QuestResult {
        let options: [QuestResult] = [.success, .fail]
        return options.randomElement() ?? .success
    }
}
