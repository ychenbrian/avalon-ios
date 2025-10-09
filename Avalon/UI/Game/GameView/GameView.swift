import Observation
import SwiftUI

private enum RoundAvailability { case locked, next, started }

private struct TeamLocator: Identifiable, Equatable {
    let roundIndex: Int
    let teamIndex: Int
    var id: String { "\(roundIndex)-\(teamIndex)" }
}

struct GameView: View {
    @Environment(GameStore.self) private var store

    @State private var activeAlert: NewRoundAlert?
    @State private var newTeam: TeamLocator?

    private var selectedRoundID: UUID? { store.game.selectedRoundID }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(store.game.rounds) { round in
                            RoundCircle(round: round, isSelected: selectedRoundID == round.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let status = availability(for: round)
                                    switch status {
                                    case .locked:
                                        activeAlert = .cannotStart
                                    case .next:
                                        activeAlert = .confirmStart(round: round)
                                    case .started:
                                        withAnimation { store.game.selectedRoundID = round.id }
                                    }
                                }
                        }
                    }
                }

                if let id = selectedRoundID, let round = store.round(id: id) {
                    RoundDetailView(roundID: round.id)
                } else {
                    ContentUnavailableView(
                        "Select a round",
                        systemImage: "train.side.front.car",
                        description: Text("Tap a circle above.")
                    )
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("\(store.game.name) - Round \((store.round(id: selectedRoundID ?? UUID())?.index ?? 0) + 1)")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        let new = store.addRound()
//                        store.game.selectedRoundID = new.id
//                    } label: {
//                        Label("Add Round", systemImage: "plus")
//                    }
//                }
//            }
        }
        .alert(item: $activeAlert) { route in
            switch route {
            case .cannotStart:
                return Alert(
                    title: Text("Cannot start this round"),
                    message: Text("You can’t start this round yet."),
                    dismissButton: .default(Text("OK"))
                )

            case let .confirmStart(round):
                return Alert(
                    title: Text("Start new round?"),
                    message: Text("Do you want to start Round \(round.index + 1)?"),
                    primaryButton: .default(Text("Start")) {
                        startRoundFlow(from: round)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .sheet(item: $newTeam) { key in
            let rIdx = key.roundIndex
            let tIdx = key.teamIndex

            if store.game.rounds.indices.contains(rIdx),
               store.game.rounds[rIdx].teams.indices.contains(tIdx)
            {
                let round = store.game.rounds[rIdx]
                let team = round.teams[tIdx]
                TeamFormSheet(
                    roundID: round.id,
                    teamID: team.id,
                    leader: team.leader,
                    players: store.players,
                    requiredTeamSize: round.requiredTeamSize,
                    onSave: { roundID, teamID, leader, members, votesByVoter in
                        store.updateTeamLeader(leader, roundID: roundID, teamID: teamID)
                        store.updateTeamMembers(members, roundID: roundID, teamID: teamID)
                        store.updateTeamVotes(votesByVoter, roundID: roundID, teamID: teamID)
                        withAnimation { newTeam = nil }
                    },
                    onCancel: { withAnimation { newTeam = nil } }
                )
                .presentationDetents([.large])
            } else {
                Color.clear.onAppear { newTeam = nil }
            }
        }
        .onAppear {
            if selectedRoundID == nil { store.game.selectedRoundID = store.game.rounds.first?.id }
        }
    }

    private func availability(for round: RoundViewData) -> RoundAvailability {
        if round.index == 0 || round.status != .notStarted { return .started }
        let previousRound = store.game.rounds[round.index - 1]
        if previousRound.status == .notStarted && round.status == .notStarted {
            return .locked
        } else {
            return .next
        }
    }

    private func startRoundFlow(from round: RoundViewData) {
        store.startRound(round.index)
        withAnimation { store.game.selectedRoundID = round.id }

        if round.teams.first != nil {
            newTeam = TeamLocator(roundIndex: round.index, teamIndex: 0)
        }
    }
}
