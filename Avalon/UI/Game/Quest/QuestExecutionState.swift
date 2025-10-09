struct QuestExecutionState {
    var leader: Player
    var team: [Player]
    var failVotes: Int
    var requiredFails: Int

    var result: QuestResult {
        return (failVotes >= requiredFails) ? .fail : .success
    }
}
