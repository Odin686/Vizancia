import Foundation

// MARK: - Duel Match Data
/// Codable struct serialized to GKTurnBasedMatch.matchData
struct DuelMatchData: Codable {
    let questionIds: [String]
    let categoryId: String
    var player1Id: String
    var player2Id: String?
    var player1Score: Int?
    var player2Score: Int?
    var player1Answers: [String: Bool]?
    var player2Answers: [String: Bool]?
    var player1Time: TimeInterval?
    var player2Time: TimeInterval?
    var createdAt: Date

    init(questionIds: [String], categoryId: String, player1Id: String) {
        self.questionIds = questionIds
        self.categoryId = categoryId
        self.player1Id = player1Id
        self.createdAt = Date()
    }

    // Encode to Data for Game Center
    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }

    // Decode from Game Center match data
    static func decode(from data: Data) -> DuelMatchData? {
        try? JSONDecoder().decode(DuelMatchData.self, from: data)
    }

    var isComplete: Bool {
        player1Score != nil && player2Score != nil
    }

    var winnerId: String? {
        guard let p1 = player1Score, let p2 = player2Score else { return nil }
        if p1 > p2 { return player1Id }
        if p2 > p1 { return player2Id }
        return nil // Tie
    }

    var isTie: Bool {
        guard let p1 = player1Score, let p2 = player2Score else { return false }
        return p1 == p2
    }
}

// MARK: - Duel Status
enum DuelStatus: String {
    case waitingForOpponent
    case yourTurn
    case waitingForResult
    case completed
    case expired
}

// MARK: - Duel XP Rewards
struct DuelRewards {
    static let winXP = 50
    static let loseXP = 15
    static let tieXP = 30
    static let perfectBonusXP = 25
}
