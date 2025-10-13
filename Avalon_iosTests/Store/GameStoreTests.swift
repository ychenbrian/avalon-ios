@testable import Avalon
import Foundation
import Testing

@Suite("GameStore Tests")
@MainActor
struct GameStoreTests {
    // MARK: - Initial Tests

    @Test("Initial GameStore with game data")
    func initialization() {
        let store = GameStore(players: Player.defaultPlayers())

        #expect(store.game.quests.count == 5)
        #expect(store.game.quests.allSatisfy { $0.teams.count == 5 })
    }

    @Test("Initial game has first quest in progress")
    func initialGameFirstQuestInProgress() {
        let store = GameStore(players: Player.defaultPlayers())

        #expect(store.game.quests[0].status == .inProgress)
        #expect(store.game.quests[0].teams[0].status == .inProgress)
    }

    @Test("Initial game has other quests not started")
    func initialGameOtherQuestsNotStarted() {
        let store = GameStore(players: Player.defaultPlayers())

        for i in 1 ..< 5 {
            #expect(store.game.quests[i].status == .notStarted)
            #expect(store.game.quests[i].teams.allSatisfy { $0.status == .notStarted })
        }
    }

    // MARK: - Query Tests

    @Test("Query quest by ID returns correct quest")
    func questQuery() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomIndex]

        let foundQuest = store.quest(id: quest.id)

        #expect(foundQuest != nil)
        #expect(foundQuest?.id == quest.id)
        #expect(foundQuest?.index == randomIndex)
    }

    @Test("Query quest with invalid ID returns nil")
    func questQueryInvalidID() {
        let store = GameStore(players: Player.defaultPlayers())

        let foundQuest = store.quest(id: UUID())

        #expect(foundQuest == nil)
    }

    @Test("Query team by ID returns correct team")
    func teamQuery() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]

        let foundTeam = store.team(id: team.id, in: quest.id)

        #expect(foundTeam != nil)
        #expect(foundTeam?.id == team.id)
        #expect(foundTeam?.index == randomTeamIndex)
    }

    @Test("Query team with invalid quest ID returns nil")
    func teamQueryInvalidQuestID() {
        let store = GameStore(players: Player.defaultPlayers())

        let foundTeam = store.team(id: UUID(), in: UUID())

        #expect(foundTeam == nil)
    }

    @Test("Query team with invalid team ID returns nil")
    func teamQueryInvalidTeamID() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]

        let foundTeam = store.team(id: UUID(), in: quest.id)

        #expect(foundTeam == nil)
    }

    // MARK: - Initial Game Tests

    @Test("Initial game resets game data")
    func testInitialGame() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        store.startQuest(2)
        let quest1 = store.game.quests[1]
        let quest2 = store.game.quests[2]
        #expect(quest1.status == .inProgress)
        #expect(quest2.status == .inProgress)

        let oldGameID = store.game.id
        store.initialGame()

        #expect(store.game.id != oldGameID)
        #expect(store.game.quests.count == 5)
        #expect(store.game.quests[0].status == .inProgress)
        #expect(store.game.quests[1].status == .notStarted)
        #expect(store.game.quests[2].status == .notStarted)
    }

    // MARK: - Quest Management Tests

    @Test("Start quest sets status to in progress")
    func testStartQuest() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomIndex = Int.random(in: 1 ..< 5) // Not 0 since it's already in progress

        #expect(store.game.quests[randomIndex].status == .notStarted)

        store.startQuest(randomIndex)

        #expect(store.game.quests[randomIndex].status == .inProgress)
        #expect(store.game.quests[randomIndex].teams[0].status == .inProgress)
    }

    @Test("Start quest only sets first team to in progress")
    func startQuestFirstTeamOnly() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomIndex = Int.random(in: 1 ..< 5)

        store.startQuest(randomIndex)

        let quest = store.game.quests[randomIndex]
        #expect(quest.teams[0].status == .inProgress)
        #expect(quest.teams[1].status == .notStarted)
        #expect(quest.teams[2].status == .notStarted)
        #expect(quest.teams[3].status == .notStarted)
        #expect(quest.teams[4].status == .notStarted)
    }

    @Test("Start multiple quests independently")
    func startMultipleQuests() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        store.startQuest(3)

        #expect(store.game.quests[1].status == .inProgress)
        #expect(store.game.quests[3].status == .inProgress)
        #expect(store.game.quests[2].status == .notStarted)
    }

    // MARK: - Update Team Tests

    @Test("Update team leader sets leader")
    func updateTeamLeader() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomLeaderIndex = Int.random(in: 0 ..< store.players.count)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]
        let leader = store.players[randomLeaderIndex]

        #expect(team.leader == nil)

        store.updateTeam(questID: quest.id, teamID: team.id, leader: leader)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.leader?.id == leader.id)
        #expect(updatedTeam?.leader?.index == randomLeaderIndex)
    }

    @Test("Update team members sets members")
    func updateTeamMembers() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomMemberCount = Int.random(in: 2 ... 5)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]
        let members = Array(store.players.prefix(randomMemberCount))

        #expect(team.members.isEmpty)

        store.updateTeam(questID: quest.id, teamID: team.id, members: members)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.members.count == randomMemberCount)
        for i in 0 ..< randomMemberCount {
            #expect(updatedTeam?.members.contains(store.players[i]) == true)
        }
    }

    @Test("Update team votes sets votes")
    func updateTeamVotes() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomVoteCount = Int.random(in: 3 ... 10)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]

        var votes: [Player: VoteType] = [:]
        for i in 0 ..< randomVoteCount {
            votes[store.players[i]] = Bool.random() ? .approve : .reject
        }

        #expect(team.votesByVoter.isEmpty)

        store.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.votesByVoter.count == randomVoteCount)
    }

    @Test("Update team with multiple properties")
    func updateTeamMultipleProperties() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]
        let team = quest.teams[0]

        let leader = store.players[0]
        let members = Array(store.players.prefix(4))
        let votes: [Player: VoteType] = [
            store.players[0]: .approve,
            store.players[1]: .approve,
        ]

        store.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.leader?.id == leader.id)
        #expect(updatedTeam?.members.count == 4)
        #expect(updatedTeam?.votesByVoter.count == 2)
    }

    @Test("Update team with invalid IDs does nothing")
    func updateTeamInvalidIDs() {
        let store = GameStore(players: Player.defaultPlayers())
        let leader = store.players.first!

        store.updateTeam(questID: UUID(), teamID: UUID(), leader: leader)

        #expect(store.game.quests.count == 5)
    }

    // MARK: - Finish Team Tests

    @Test("Finish team with majority approvals marks as approved")
    func finishTeamApproved() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]

        let approveCount = Int.random(in: 6 ... 8)
        let rejectCount = 10 - approveCount
        var votes: [Player: VoteType] = [:]
        for i in 0 ..< approveCount {
            votes[store.players[i]] = .approve
        }
        for i in approveCount ..< 10 {
            votes[store.players[i]] = .reject
        }

        store.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        store.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == true)
        #expect(updatedTeam?.result?.approvedCount == approveCount)
        #expect(updatedTeam?.result?.rejectedCount == rejectCount)
    }

    @Test("Finish team with majority rejections marks as rejected")
    func finishTeamRejected() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let team = quest.teams[randomTeamIndex]

        let rejectCount = Int.random(in: 6 ... 8)
        let approveCount = 10 - rejectCount
        var votes: [Player: VoteType] = [:]
        for i in 0 ..< approveCount {
            votes[store.players[i]] = .approve
        }
        for i in approveCount ..< 10 {
            votes[store.players[i]] = .reject
        }

        store.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        store.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == false)
        #expect(updatedTeam?.result?.approvedCount == approveCount)
        #expect(updatedTeam?.result?.rejectedCount == rejectCount)
    }

    @Test("Finish team with tie votes favors rejection")
    func finishTeamTieVotes() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]
        let team = quest.teams[1]

        let votes: [Player: VoteType] = [
            store.players[0]: .approve,
            store.players[1]: .approve,
            store.players[2]: .approve,
            store.players[3]: .reject,
            store.players[4]: .reject,
            store.players[5]: .reject,
        ]
        store.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        store.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.result?.isApproved == false)
    }

    @Test("Finish team with no votes")
    func finishTeamNoVotes() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]
        let team = quest.teams[0]

        store.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.approvedCount == 0)
        #expect(updatedTeam?.result?.rejectedCount == 0)
        #expect(updatedTeam?.result?.isApproved == false)
    }

    // MARK: - Update Quest Result Tests

    @Test("Update quest result with enough fails marks as failed")
    func updateQuestResultFailed() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let failCount = Int.random(in: quest.requiredFails ... (quest.requiredFails + 2))

        store.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .fail)
        #expect(updatedQuest?.result?.failCount == failCount)
    }

    @Test("Update quest result with no fails marks as success")
    func updateQuestResultSuccess() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let failCount = Int.random(in: 0 ..< quest.requiredFails)

        store.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)
        #expect(updatedQuest?.result?.failCount == failCount)
    }

    @Test("Update quest result respects required fails threshold")
    func updateQuestResultThreshold() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[3]

        let requiredFails = quest.requiredFails

        store.updateQuestResult(questID: quest.id, failCount: requiredFails - 1)
        var updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.result?.type == .success)

        store.initialGame()
        let newQuest = store.game.quests[3]
        store.updateQuestResult(questID: newQuest.id, failCount: requiredFails)
        updatedQuest = store.quest(id: newQuest.id)
        #expect(updatedQuest?.result?.type == .fail)
    }

    @Test("Update quest result with excessive fails still marks as failed")
    func updateQuestResultExcessiveFails() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[2]

        store.updateQuestResult(questID: quest.id, failCount: 5)

        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.result?.type == .fail)
        #expect(updatedQuest?.result?.failCount == 5)
    }

    @Test("Clear quest result")
    func clearQuestResult() {
        let store = GameStore(players: Player.defaultPlayers())
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = store.game.quests[randomQuestIndex]
        let failCount = Int.random(in: 0 ..< quest.requiredFails)

        store.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)

        store.clearQuestResult(questID: quest.id)

        let clearedQuest = store.quest(id: quest.id)
        #expect(clearedQuest?.status == .inProgress)
        #expect(clearedQuest?.result == nil)
    }

    // MARK: - Integration Tests

    @Test("Complete successful quest flow")
    func completeSuccessfulQuestFlow() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]
        let team = quest.teams[0]

        #expect(quest.status == .inProgress)
        #expect(team.status == .inProgress)

        let leader = store.players[0]
        let members = Array(store.players.prefix(3))
        let votes: [Player: VoteType] = [
            store.players[0]: .approve,
            store.players[1]: .approve,
            store.players[2]: .approve,
            store.players[3]: .approve,
            store.players[4]: .approve,
            store.players[5]: .approve,
            store.players[6]: .approve,
            store.players[7]: .reject,
            store.players[8]: .reject,
            store.players[9]: .reject,
        ]

        store.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        store.finishTeam(questID: quest.id, teamID: team.id)
        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == true)
        #expect(updatedTeam?.result?.approvedCount == 7)

        store.updateQuestResult(questID: quest.id, failCount: 0)
        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)
    }

    @Test("Complete failed quest flow")
    func completeFailedQuestFlow() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        let quest = store.game.quests[1]
        let team = quest.teams[0]

        let leader = store.players[1]
        let members = Array(store.players[2 ... 5])
        let votes: [Player: VoteType] = [
            store.players[0]: .reject,
            store.players[1]: .reject,
            store.players[2]: .reject,
            store.players[3]: .reject,
            store.players[4]: .reject,
            store.players[5]: .reject,
            store.players[6]: .approve,
            store.players[7]: .approve,
            store.players[8]: .approve,
            store.players[9]: .approve,
        ]

        store.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        store.finishTeam(questID: quest.id, teamID: team.id)
        let updatedTeam = store.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.result?.isApproved == false)

        store.updateQuestResult(questID: quest.id, failCount: 2)
        let updatedQuest = store.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .fail)
    }

    @Test("Multiple quests progression")
    func multipleQuestsProgression() {
        let store = GameStore(players: Player.defaultPlayers())

        let quest1 = store.game.quests[0]
        store.updateQuestResult(questID: quest1.id, failCount: 0)
        #expect(quest1.status == .finished)

        store.startQuest(1)
        let quest2 = store.game.quests[1]
        #expect(quest2.status == .inProgress)
        store.updateQuestResult(questID: quest2.id, failCount: 1)
        #expect(quest2.status == .finished)

        store.startQuest(2)
        let quest3 = store.game.quests[2]
        #expect(quest3.status == .inProgress)

        #expect(store.game.quests[0].status == .finished)
        #expect(store.game.quests[1].status == .finished)
        #expect(store.game.quests[2].status == .inProgress)
        #expect(store.game.quests[3].status == .notStarted)
        #expect(store.game.quests[4].status == .notStarted)
    }

    @Test("Multiple team proposals in a quest")
    func multipleTeamProposals() {
        let store = GameStore(players: Player.defaultPlayers())
        let quest = store.game.quests[0]

        let team1 = quest.teams[0]
        let votes1: [Player: VoteType] = Dictionary(
            uniqueKeysWithValues: store.players.map { ($0, VoteType.reject) }
        )
        store.updateTeam(questID: quest.id, teamID: team1.id, votesByVoter: votes1)
        store.finishTeam(questID: quest.id, teamID: team1.id)
        #expect(team1.result?.isApproved == false)

        let team2 = quest.teams[1]
        let votes2: [Player: VoteType] = Dictionary(
            uniqueKeysWithValues: store.players.map { ($0, VoteType.approve) }
        )
        store.updateTeam(questID: quest.id, teamID: team2.id, votesByVoter: votes2)
        store.finishTeam(questID: quest.id, teamID: team2.id)
        #expect(team2.result?.isApproved == true)

        #expect(quest.teams[0].status == .finished)
        #expect(quest.teams[1].status == .finished)
        #expect(quest.teams[0].result?.isApproved == false)
        #expect(quest.teams[1].result?.isApproved == true)
    }

    @Test("Reset game after progression")
    func resetGameAfterProgression() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        store.startQuest(2)

        let quest1 = store.game.quests[0]
        let quest2 = store.game.quests[1]
        _ = store.updateQuestResult(questID: quest1.id, failCount: 0)
        _ = store.updateQuestResult(questID: quest2.id, failCount: 1)

        #expect(quest1.status == .finished)
        #expect(quest2.status == .finished)

        store.initialGame()

        #expect(store.game.quests.count == 5)
        #expect(store.game.quests[0].status == .inProgress)
        #expect(store.game.quests[1].status == .notStarted)
        #expect(store.game.quests[0].result?.type == nil)
        #expect(store.game.quests[1].result?.type == nil)
    }

    @Test("Check game not finish with 1 success")
    func checkGameNotFinishWithOneSuccess() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)

        let quest = store.game.quests[0]
        let hasFinished = store.updateQuestResult(questID: quest.id, failCount: 0)

        #expect(hasFinished == false)
    }

    @Test("Check game not finish with 2 successes and 2 fails")
    func checkGameNotFinishWithTwoSuccessesAndTwoFails() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        let quest1 = store.game.quests[0]
        let hasFinished1 = store.updateQuestResult(questID: quest1.id, failCount: 0)

        store.startQuest(2)
        let quest2 = store.game.quests[1]
        let hasFinished2 = store.updateQuestResult(questID: quest2.id, failCount: 1)

        store.startQuest(3)
        let quest3 = store.game.quests[2]
        let hasFinished3 = store.updateQuestResult(questID: quest3.id, failCount: 1)

        store.startQuest(4)
        let quest4 = store.game.quests[3]
        let hasFinished4 = store.updateQuestResult(questID: quest4.id, failCount: 0)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == false)
        #expect(hasFinished4 == false)
    }

    @Test("Check game finish with 3 successes")
    func checkGameFinishWithThreeSuccesses() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        let quest1 = store.game.quests[0]
        let hasFinished1 = store.updateQuestResult(questID: quest1.id, failCount: 0)

        store.startQuest(2)
        let quest2 = store.game.quests[1]
        let hasFinished2 = store.updateQuestResult(questID: quest2.id, failCount: 0)

        store.startQuest(3)
        let quest3 = store.game.quests[2]
        let hasFinished3 = store.updateQuestResult(questID: quest3.id, failCount: 0)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == true)
    }

    @Test("Check game finish with 3 fails")
    func checkGameFinishWithThreeFails() {
        let store = GameStore(players: Player.defaultPlayers())

        store.startQuest(1)
        let quest1 = store.game.quests[0]
        let hasFinished1 = store.updateQuestResult(questID: quest1.id, failCount: 1)

        store.startQuest(2)
        let quest2 = store.game.quests[1]
        let hasFinished2 = store.updateQuestResult(questID: quest2.id, failCount: 1)

        store.startQuest(3)
        let quest3 = store.game.quests[2]
        let hasFinished3 = store.updateQuestResult(questID: quest3.id, failCount: 1)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == true)
    }
}
