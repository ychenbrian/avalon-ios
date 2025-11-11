@testable import Avalon
import Foundation
import Testing

@MainActor
private func makePresenter() async -> GamePresenter {
    let interactor = MockGamesInteractor()
    let presenter = GamePresenter(interactor: interactor)
    await presenter.createNewGame(resetPlayersToDefault: true)
    return presenter
}

@Suite("GamePresenter Tests")
@MainActor
struct GamePresenterTests {
    // MARK: - Initial Tests

    @Test("Initial GamePresenter with game data")
    func initialization() async {
        let presenter = await makePresenter()

        #expect(presenter.game.sortedQuests.count == 5)
        #expect(presenter.game.sortedQuests.allSatisfy { $0.sortedTeams.count == 5 })
    }

    @Test("Initial game has first quest in progress")
    func initialGameFirstQuestInProgress() async {
        let presenter = await makePresenter()

        #expect(presenter.game.sortedQuests[0].status == .inProgress)
        #expect(presenter.game.sortedQuests[0].sortedTeams[0].status == .inProgress)
    }

    @Test("Initial game has other quests not started")
    func initialGameOtherQuestsNotStarted() async {
        let presenter = await makePresenter()

        for i in 1 ..< 5 {
            #expect(presenter.game.sortedQuests[i].status == .notStarted)
            #expect(presenter.game.sortedQuests[i].sortedTeams.allSatisfy { $0.status == .notStarted })
        }
    }

    // MARK: - Query Tests

    @Test("Query quest by ID returns correct quest")
    func questQuery() async {
        let presenter = await makePresenter()
        let randomIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomIndex]

        let foundQuest = presenter.quest(id: quest.id)

        #expect(foundQuest != nil)
        #expect(foundQuest?.id == quest.id)
        #expect(foundQuest?.index == randomIndex)
    }

    @Test("Query quest with invalid ID returns nil")
    func questQueryInvalidID() async {
        let presenter = await makePresenter()

        let foundQuest = presenter.quest(id: UUID())

        #expect(foundQuest == nil)
    }

    @Test("Query team by ID returns correct team")
    func teamQuery() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]

        let foundTeam = presenter.team(id: team.id, in: quest.id)

        #expect(foundTeam != nil)
        #expect(foundTeam?.id == team.id)
        #expect(foundTeam?.teamIndex == randomTeamIndex)
    }

    @Test("Query team with invalid quest ID returns nil")
    func teamQueryInvalidQuestID() async {
        let presenter = await makePresenter()

        let foundTeam = presenter.team(id: UUID(), in: UUID())

        #expect(foundTeam == nil)
    }

    @Test("Query team with invalid team ID returns nil")
    func teamQueryInvalidTeamID() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]

        let foundTeam = presenter.team(id: UUID(), in: quest.id)

        #expect(foundTeam == nil)
    }

    // MARK: - Initial Game Tests

    @Test("Initial game resets game data")
    func initialGame() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        await presenter.startQuest(2)
        let quest1 = presenter.game.sortedQuests[1]
        let quest2 = presenter.game.sortedQuests[2]
        #expect(quest1.status == .inProgress)
        #expect(quest2.status == .inProgress)

        let oldGameID = presenter.game.id
        await presenter.createNewGame()

        #expect(presenter.game.id != oldGameID)
        #expect(presenter.game.sortedQuests.count == 5)
        #expect(presenter.game.sortedQuests[0].status == .inProgress)
        #expect(presenter.game.sortedQuests[1].status == .notStarted)
        #expect(presenter.game.sortedQuests[2].status == .notStarted)
    }

    // MARK: - Game Update Tests

    @Test("Update number of players with game reset")
    func udpdateNumberOfPlayersWithGameReset() async {
        let presenter = await makePresenter()
        let oldGameID = presenter.game.id

        let numOfPlayers = Int.random(in: 5 ..< 11)
        await presenter.updateNumOfPlayers(numOfPlayers)

        #expect(presenter.players.count == numOfPlayers)
        #expect(presenter.game.id != oldGameID)
    }

    @Test("Update game name without game reset")
    func updateGameNameWithoutGameReset() async {
        let presenter = await makePresenter()
        let gameID = presenter.game.id

        let newGameName = "New Game Name"
        await presenter.updateGameDetails(gameName: newGameName)

        #expect(presenter.game.name == newGameName)
        #expect(presenter.game.id == gameID)
    }

    // MARK: - Quest Management Tests

    @Test("Start quest sets status to in progress")
    func testStartQuest() async {
        let presenter = await makePresenter()
        let randomIndex = Int.random(in: 1 ..< 5)

        #expect(presenter.game.sortedQuests[randomIndex].status == .notStarted)

        await presenter.startQuest(randomIndex)

        #expect(presenter.game.sortedQuests[randomIndex].status == .inProgress)
        #expect(presenter.game.sortedQuests[randomIndex].sortedTeams[0].status == .inProgress)
    }

    @Test("Start quest only sets first team to in progress")
    func startQuestFirstTeamOnly() async {
        let presenter = await makePresenter()
        let randomIndex = Int.random(in: 1 ..< 5)

        await presenter.startQuest(randomIndex)

        let quest = presenter.game.sortedQuests[randomIndex]
        #expect(quest.sortedTeams[0].status == .inProgress)
        #expect(quest.sortedTeams[1].status == .notStarted)
        #expect(quest.sortedTeams[2].status == .notStarted)
        #expect(quest.sortedTeams[3].status == .notStarted)
        #expect(quest.sortedTeams[4].status == .notStarted)
    }

    @Test("Start multiple quests independently")
    func startMultipleQuests() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        await presenter.startQuest(3)

        #expect(presenter.game.sortedQuests[1].status == .inProgress)
        #expect(presenter.game.sortedQuests[3].status == .inProgress)
        #expect(presenter.game.sortedQuests[2].status == .notStarted)
    }

    // MARK: - Update Team Tests

    @Test("Update team leader sets leader")
    func updateTeamLeader() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomLeaderIndex = Int.random(in: 0 ..< presenter.players.count)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]
        let leader = presenter.players[randomLeaderIndex]

        #expect(team.leader == nil)

        await presenter.updateTeam(questID: quest.id, teamID: team.id, leader: leader)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.leader?.id == leader.id)
        #expect(updatedTeam?.leader?.index == randomLeaderIndex)
    }

    @Test("Update team members sets members")
    func updateTeamMembers() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomMemberCount = Int.random(in: 2 ... 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]
        let members = Array(presenter.players.prefix(randomMemberCount))

        #expect(team.members.isEmpty)

        await presenter.updateTeam(questID: quest.id, teamID: team.id, members: members)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.members.count == randomMemberCount)
        for i in 0 ..< randomMemberCount {
            #expect(updatedTeam?.members.contains(presenter.players[i]) == true)
        }
    }

    @Test("Update team votes sets votes")
    func updateTeamVotes() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let randomVoteCount = Int.random(in: 3 ... presenter.players.count)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]

        var votes: [PlayerID: VoteType] = [:]
        for i in 0 ..< randomVoteCount {
            votes[presenter.players[i].id] = Bool.random() ? .approve : .reject
        }

        #expect(team.votesByVoter.isEmpty)

        await presenter.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.votesByVoter.count == randomVoteCount)
    }

    @Test("Update team with multiple properties")
    func updateTeamMultipleProperties() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]
        let team = quest.sortedTeams[0]

        let leader = presenter.players[0]
        let members = Array(presenter.players.prefix(4))
        let votes: [PlayerID: VoteType] = [
            presenter.players[0].id: .approve,
            presenter.players[1].id: .approve,
        ]

        await presenter.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.leader?.id == leader.id)
        #expect(updatedTeam?.members.count == 4)
        #expect(updatedTeam?.votesByVoter.count == 2)
    }

    @Test("Update team with invalid IDs does nothing")
    func updateTeamInvalidIDs() async {
        let presenter = await makePresenter()
        let leader = presenter.players.first!

        await presenter.updateTeam(questID: UUID(), teamID: UUID(), leader: leader)

        #expect(presenter.game.sortedQuests.count == 5)
    }

    // MARK: - Finish Team Tests

    @Test("Finish team with majority approvals marks as approved")
    func finishTeamApproved() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]

        let approveCount = Int.random(in: 6 ... 8)
        let rejectCount = presenter.players.count - approveCount
        var votes: [PlayerID: VoteType] = [:]
        for i in 0 ..< approveCount {
            votes[presenter.players[i].id] = .approve
        }
        for i in approveCount ..< presenter.players.count {
            votes[presenter.players[i].id] = .reject
        }

        await presenter.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)
        await presenter.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == true)
        #expect(updatedTeam?.result?.approvedCount == approveCount)
        #expect(updatedTeam?.result?.rejectedCount == rejectCount)
    }

    @Test("Finish team with majority rejections marks as rejected")
    func finishTeamRejected() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let randomTeamIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let team = quest.sortedTeams[randomTeamIndex]

        let rejectCount = Int.random(in: 6 ... 8)
        let approveCount = presenter.players.count - rejectCount
        var votes: [PlayerID: VoteType] = [:]
        for i in 0 ..< approveCount {
            votes[presenter.players[i].id] = .approve
        }
        for i in approveCount ..< presenter.players.count {
            votes[presenter.players[i].id] = .reject
        }

        await presenter.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)
        await presenter.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == false)
        #expect(updatedTeam?.result?.approvedCount == approveCount)
        #expect(updatedTeam?.result?.rejectedCount == rejectCount)
    }

    @Test("Finish team with tie votes favors rejection")
    func finishTeamTieVotes() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]
        let team = quest.sortedTeams[1]

        let votes: [PlayerID: VoteType] = [
            presenter.players[0].id: .approve,
            presenter.players[1].id: .approve,
            presenter.players[2].id: .approve,
            presenter.players[3].id: .reject,
            presenter.players[4].id: .reject,
            presenter.players[5].id: .reject,
        ]
        await presenter.updateTeam(questID: quest.id, teamID: team.id, votesByVoter: votes)

        await presenter.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.result?.isApproved == false)
    }

    @Test("Finish team with no votes")
    func finishTeamNoVotes() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]
        let team = quest.sortedTeams[0]

        await presenter.finishTeam(questID: quest.id, teamID: team.id)

        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.approvedCount == 0)
        #expect(updatedTeam?.result?.rejectedCount == 0)
        #expect(updatedTeam?.result?.isApproved == false)
    }

    // MARK: - Update Quest Result Tests

    @Test("Update quest result with enough fails marks as failed")
    func updateQuestResultFailed() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let failCount = Int.random(in: quest.requiredFails ... (quest.requiredFails + 2))

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .fail)
        #expect(updatedQuest?.result?.failCount == failCount)
    }

    @Test("Update quest result with no fails marks as success")
    func updateQuestResultSuccess() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let failCount = Int.random(in: 0 ..< quest.requiredFails)

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)
        #expect(updatedQuest?.result?.failCount == failCount)
    }

    @Test("Update quest result respects required fails threshold")
    func updateQuestResultThreshold() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[3]

        let requiredFails = quest.requiredFails

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: requiredFails - 1)
        var updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.result?.type == .success)

        await presenter.createNewGame()
        let newQuest = presenter.game.sortedQuests[3]
        _ = await presenter.updateQuestResult(questID: newQuest.id, failCount: requiredFails)
        updatedQuest = presenter.quest(id: newQuest.id)
        #expect(updatedQuest?.result?.type == .fail)
    }

    @Test("Update quest result with excessive fails still marks as failed")
    func updateQuestResultExcessiveFails() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[2]

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: 5)

        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.result?.type == .fail)
        #expect(updatedQuest?.result?.failCount == 5)
    }

    @Test("Clear quest result")
    func clearQuestResult() async {
        let presenter = await makePresenter()
        let randomQuestIndex = Int.random(in: 0 ..< 5)
        let quest = presenter.game.sortedQuests[randomQuestIndex]
        let failCount = Int.random(in: 0 ..< quest.requiredFails)

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: failCount)

        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)

        await presenter.clearQuestResult(questID: quest.id)

        let clearedQuest = presenter.quest(id: quest.id)
        #expect(clearedQuest?.status == .inProgress)
        #expect(clearedQuest?.result == nil)
    }

    // MARK: - Integration Tests

    @Test("Complete successful quest flow")
    func completeSuccessfulQuestFlow() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]
        let team = quest.sortedTeams[0]

        #expect(quest.status == .inProgress)
        #expect(team.status == .inProgress)

        let leader = presenter.players[0]
        let members = Array(presenter.players.prefix(3))
        let votes: [PlayerID: VoteType] = [
            presenter.players[0].id: .approve,
            presenter.players[1].id: .approve,
            presenter.players[2].id: .approve,
            presenter.players[3].id: .approve,
            presenter.players[4].id: .approve,
            presenter.players[5].id: .approve,
            presenter.players[6].id: .approve,
            presenter.players[7].id: .reject,
            presenter.players[8].id: .reject,
            presenter.players[9].id: .reject,
        ]

        await presenter.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        await presenter.finishTeam(questID: quest.id, teamID: team.id)
        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.status == .finished)
        #expect(updatedTeam?.result?.isApproved == true)
        #expect(updatedTeam?.result?.approvedCount == 7)

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: 0)
        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .success)
    }

    @Test("Complete failed quest flow")
    func completeFailedQuestFlow() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        let quest = presenter.game.sortedQuests[1]
        let team = quest.sortedTeams[0]

        let leader = presenter.players[1]
        let members = Array(presenter.players[2 ... 5])
        let votes: [PlayerID: VoteType] = [
            presenter.players[0].id: .reject,
            presenter.players[1].id: .reject,
            presenter.players[2].id: .reject,
            presenter.players[3].id: .reject,
            presenter.players[4].id: .reject,
            presenter.players[5].id: .reject,
            presenter.players[6].id: .approve,
            presenter.players[7].id: .approve,
            presenter.players[8].id: .approve,
            presenter.players[9].id: .approve,
        ]

        await presenter.updateTeam(
            questID: quest.id,
            teamID: team.id,
            leader: leader,
            members: members,
            votesByVoter: votes
        )

        await presenter.finishTeam(questID: quest.id, teamID: team.id)
        let updatedTeam = presenter.team(id: team.id, in: quest.id)
        #expect(updatedTeam?.result?.isApproved == false)

        _ = await presenter.updateQuestResult(questID: quest.id, failCount: 2)
        let updatedQuest = presenter.quest(id: quest.id)
        #expect(updatedQuest?.status == .finished)
        #expect(updatedQuest?.result?.type == .fail)
    }

    @Test("Multiple quests progression")
    func multipleQuestsProgression() async {
        let presenter = await makePresenter()

        let quest1 = presenter.game.sortedQuests[0]
        _ = await presenter.updateQuestResult(questID: quest1.id, failCount: 0)
        #expect(quest1.status == .finished)

        await presenter.startQuest(1)
        let quest2 = presenter.game.sortedQuests[1]
        #expect(quest2.status == .inProgress)
        _ = await presenter.updateQuestResult(questID: quest2.id, failCount: 1)
        #expect(quest2.status == .finished)

        await presenter.startQuest(2)
        let quest3 = presenter.game.sortedQuests[2]
        #expect(quest3.status == .inProgress)

        #expect(presenter.game.sortedQuests[0].status == .finished)
        #expect(presenter.game.sortedQuests[1].status == .finished)
        #expect(presenter.game.sortedQuests[2].status == .inProgress)
        #expect(presenter.game.sortedQuests[3].status == .notStarted)
        #expect(presenter.game.sortedQuests[4].status == .notStarted)
    }

    @Test("Multiple team proposals in a quest")
    func multipleTeamProposals() async {
        let presenter = await makePresenter()
        let quest = presenter.game.sortedQuests[0]

        let team1 = quest.sortedTeams[0]
        let votes1: [PlayerID: VoteType] = Dictionary(
            uniqueKeysWithValues: presenter.players.map { ($0.id, VoteType.reject) }
        )
        await presenter.updateTeam(questID: quest.id, teamID: team1.id, votesByVoter: votes1)
        await presenter.finishTeam(questID: quest.id, teamID: team1.id)
        #expect(team1.result?.isApproved == false)

        let team2 = quest.sortedTeams[1]
        let votes2: [PlayerID: VoteType] = Dictionary(
            uniqueKeysWithValues: presenter.players.map { ($0.id, VoteType.approve) }
        )
        await presenter.updateTeam(questID: quest.id, teamID: team2.id, votesByVoter: votes2)
        await presenter.finishTeam(questID: quest.id, teamID: team2.id)
        #expect(team2.result?.isApproved == true)

        #expect(quest.sortedTeams[0].status == .finished)
        #expect(quest.sortedTeams[1].status == .finished)
        #expect(quest.sortedTeams[0].result?.isApproved == false)
        #expect(quest.sortedTeams[1].result?.isApproved == true)
    }

    @Test("Reset game after progression")
    func resetGameAfterProgression() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        await presenter.startQuest(2)

        let quest1 = presenter.game.sortedQuests[0]
        let quest2 = presenter.game.sortedQuests[1]
        _ = await presenter.updateQuestResult(questID: quest1.id, failCount: 0)
        _ = await presenter.updateQuestResult(questID: quest2.id, failCount: 1)

        #expect(quest1.status == .finished)
        #expect(quest2.status == .finished)

        await presenter.createNewGame()

        #expect(presenter.game.sortedQuests.count == 5)
        #expect(presenter.game.sortedQuests[0].status == .inProgress)
        #expect(presenter.game.sortedQuests[1].status == .notStarted)
        #expect(presenter.game.sortedQuests[0].result?.type == nil)
        #expect(presenter.game.sortedQuests[1].result?.type == nil)
    }

    @Test("Check game not finish with 1 success")
    func checkGameNotFinishWithOneSuccess() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)

        let quest = presenter.game.sortedQuests[0]
        let hasFinished = await presenter.updateQuestResult(questID: quest.id, failCount: 0)

        #expect(hasFinished == false)
    }

    @Test("Check game not finish with 2 successes and 2 fails")
    func checkGameNotFinishWithTwoSuccessesAndTwoFails() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        let quest1 = presenter.game.sortedQuests[0]
        let hasFinished1 = await presenter.updateQuestResult(questID: quest1.id, failCount: 0)

        await presenter.startQuest(2)
        let quest2 = presenter.game.sortedQuests[1]
        let hasFinished2 = await presenter.updateQuestResult(questID: quest2.id, failCount: 1)

        await presenter.startQuest(3)
        let quest3 = presenter.game.sortedQuests[2]
        let hasFinished3 = await presenter.updateQuestResult(questID: quest3.id, failCount: 1)

        await presenter.startQuest(4)
        let quest4 = presenter.game.sortedQuests[3]
        let hasFinished4 = await presenter.updateQuestResult(questID: quest4.id, failCount: 0)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == false)
        #expect(hasFinished4 == false)
    }

    @Test("Check game finish with 3 successes")
    func checkGameFinishWithThreeSuccesses() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        let quest1 = presenter.game.sortedQuests[0]
        let hasFinished1 = await presenter.updateQuestResult(questID: quest1.id, failCount: 0)

        await presenter.startQuest(2)
        let quest2 = presenter.game.sortedQuests[1]
        let hasFinished2 = await presenter.updateQuestResult(questID: quest2.id, failCount: 0)

        await presenter.startQuest(3)
        let quest3 = presenter.game.sortedQuests[2]
        let hasFinished3 = await presenter.updateQuestResult(questID: quest3.id, failCount: 0)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == true)
    }

    @Test("Check game finish with 3 fails")
    func checkGameFinishWithThreeFails() async {
        let presenter = await makePresenter()

        await presenter.startQuest(1)
        let quest1 = presenter.game.sortedQuests[0]
        let hasFinished1 = await presenter.updateQuestResult(questID: quest1.id, failCount: 1)

        await presenter.startQuest(2)
        let quest2 = presenter.game.sortedQuests[1]
        let hasFinished2 = await presenter.updateQuestResult(questID: quest2.id, failCount: 1)

        await presenter.startQuest(3)
        let quest3 = presenter.game.sortedQuests[2]
        let hasFinished3 = await presenter.updateQuestResult(questID: quest3.id, failCount: 1)

        #expect(hasFinished1 == false)
        #expect(hasFinished2 == false)
        #expect(hasFinished3 == true)
    }
}
