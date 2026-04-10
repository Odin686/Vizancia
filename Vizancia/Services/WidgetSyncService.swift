import Foundation
import WidgetKit

// MARK: - Widget Data Sync Service
/// Pushes user data to the widget extension via shared App Group UserDefaults.
/// Call this every time relevant data changes (XP, streak, lessons).

class WidgetSyncService {
    static let shared = WidgetSyncService()

    private let appGroupID = "group.ca.vizancia.shared"

    /// Sync current user data to widget
    func syncToWidget(user: UserProfile) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        let dueCount = SpacedRepetitionService.shared.dueCount(for: user)

        let widgetData = WidgetDataPayload(
            totalXP: user.totalXP,
            currentStreak: user.currentStreak,
            currentLevel: user.currentLevel,
            levelTitle: user.levelTitle,
            todayXP: user.todayXP,
            dailyXPGoal: user.dailyXPGoal,
            dailyGoalMet: user.dailyGoalMet,
            hasCompletedDailyChallenge: user.hasCompletedDailyChallenge,
            dueReviewCount: dueCount,
            duelWins: user.duelWins
        )

        if let data = try? JSONEncoder().encode(widgetData) {
            defaults.set(data, forKey: "widgetData")
        }

        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Payload (matches VizanciaWidgetData in widget target)
private struct WidgetDataPayload: Codable {
    var totalXP: Int
    var currentStreak: Int
    var currentLevel: Int
    var levelTitle: String
    var todayXP: Int
    var dailyXPGoal: Int
    var dailyGoalMet: Bool
    var hasCompletedDailyChallenge: Bool
    var dueReviewCount: Int
    var duelWins: Int
}
