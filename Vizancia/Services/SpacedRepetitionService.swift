import Foundation

// MARK: - Spaced Repetition Service (Leitner System)
/// Questions live in "boxes" 1-5. Correct answers promote to the next box,
/// wrong answers demote back to box 1. Higher boxes have longer review intervals.

class SpacedRepetitionService {
    static let shared = SpacedRepetitionService()

    // Box review intervals (in days)
    private let boxIntervals: [Int: Int] = [
        1: 1,   // Every day
        2: 2,   // Every 2 days
        3: 4,   // Every 4 days
        4: 8,   // Every 8 days
        5: 16   // Every 16 days (mastered)
    ]

    // MARK: - Get Due Questions

    /// Returns questions that are due for review based on the Leitner schedule
    func dueQuestions(for user: UserProfile, limit: Int = 15) -> [Question] {
        let today = Date().startOfDay
        var dueIds: [(id: String, box: Int)] = []

        for (questionId, card) in user.spacedRepetitionCards {
            let interval = boxIntervals[card.box] ?? 1
            if let lastReview = card.lastReviewDate {
                let daysSince = Calendar.current.dateComponents([.day], from: lastReview.startOfDay, to: today).day ?? 0
                if daysSince >= interval {
                    dueIds.append((id: questionId, box: card.box))
                }
            } else {
                // Never reviewed — always due
                dueIds.append((id: questionId, box: card.box))
            }
        }

        // Priority: lower boxes first (weakest questions first)
        dueIds.sort { $0.box < $1.box }

        let ids = dueIds.prefix(limit).map { $0.id }
        return LessonContentProvider.shared.missedQuestions(for: Array(ids))
    }

    /// Returns count of questions due for review
    func dueCount(for user: UserProfile) -> Int {
        let today = Date().startOfDay
        var count = 0

        for (_, card) in user.spacedRepetitionCards {
            let interval = boxIntervals[card.box] ?? 1
            if let lastReview = card.lastReviewDate {
                let daysSince = Calendar.current.dateComponents([.day], from: lastReview.startOfDay, to: today).day ?? 0
                if daysSince >= interval { count += 1 }
            } else {
                count += 1
            }
        }

        return count
    }

    // MARK: - Record Answer

    /// Move card to appropriate box based on correctness
    func recordAnswer(for user: UserProfile, questionId: String, correct: Bool) {
        if var card = user.spacedRepetitionCards[questionId] {
            if correct {
                card.box = min(5, card.box + 1)
                card.correctCount += 1
            } else {
                card.box = 1  // Demote to box 1
                card.incorrectCount += 1
            }
            card.lastReviewDate = Date()
            card.totalReviews += 1
            user.spacedRepetitionCards[questionId] = card
        } else {
            // First time seeing this question
            user.spacedRepetitionCards[questionId] = SpacedRepetitionCard(
                box: correct ? 2 : 1,
                lastReviewDate: Date(),
                correctCount: correct ? 1 : 0,
                incorrectCount: correct ? 0 : 1,
                totalReviews: 1
            )
        }
    }

    // MARK: - Add Question to Spaced Repetition

    /// Add a newly missed question to the spaced repetition deck
    func addQuestion(_ questionId: String, for user: UserProfile) {
        if user.spacedRepetitionCards[questionId] == nil {
            user.spacedRepetitionCards[questionId] = SpacedRepetitionCard(
                box: 1,
                lastReviewDate: nil,
                correctCount: 0,
                incorrectCount: 0,
                totalReviews: 0
            )
        }
    }

    // MARK: - Stats

    /// Returns distribution of cards across boxes
    func boxDistribution(for user: UserProfile) -> [Int: Int] {
        var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        for (_, card) in user.spacedRepetitionCards {
            distribution[card.box, default: 0] += 1
        }
        return distribution
    }

    /// Returns mastery percentage (cards in box 4-5 / total)
    func masteryPercentage(for user: UserProfile) -> Double {
        let total = user.spacedRepetitionCards.count
        guard total > 0 else { return 0 }
        let mastered = user.spacedRepetitionCards.values.filter { $0.box >= 4 }.count
        return Double(mastered) / Double(total)
    }

    /// Box label for display
    func boxLabel(_ box: Int) -> String {
        switch box {
        case 1: return "Learning"
        case 2: return "Familiar"
        case 3: return "Practicing"
        case 4: return "Confident"
        case 5: return "Mastered"
        default: return "Unknown"
        }
    }

    func boxColor(_ box: Int) -> String {
        switch box {
        case 1: return "aiError"
        case 2: return "aiOrange"
        case 3: return "aiWarning"
        case 4: return "aiSecondary"
        case 5: return "aiSuccess"
        default: return "aiTextSecondary"
        }
    }
}
