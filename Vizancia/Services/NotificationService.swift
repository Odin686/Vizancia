import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    // MARK: - Notification Categories
    private enum NotificationID {
        static let streakReminder = "streak_reminder"
        static let dailyChallenge = "daily_challenge"
        static let duelTurn = "duel_turn"
        static let heartsRefilled = "hearts_refilled"
        static let weeklyReport = "weekly_report"
        static let inactivity = "inactivity_nudge"
        static let streakAtRisk = "streak_at_risk"
    }

    // MARK: - Message Banks
    private let streakMessages = [
        "Don't lose your %d-day streak! 🔥 Just one lesson keeps it alive.",
        "Your %d-day streak is on the line! 🏔️ Quick — do a lesson!",
        "%d days strong! 💪 Keep the streak going today.",
        "Your streak is waiting for you! %d days and counting 🚀",
    ]

    private let challengeMessages = [
        "Your Daily Challenge is ready! ⭐ Earn bonus XP today.",
        "New question of the day! 🧠 Can you get it right?",
        "Today's AI challenge awaits! 🎯 Don't miss out on bonus XP.",
    ]

    private let comeBackMessages = [
        "We miss you! 😊 Your AI journey is waiting.",
        "Just 2 minutes a day makes a difference! 🧠 Come back and learn.",
        "Your mascot misses you! 🤖 Let's learn something new.",
        "AI is evolving fast — stay sharp with a quick lesson! ⚡",
    ]

    private let generalMessages = [
        "Your AI knowledge streak is waiting! 🔥",
        "5 minutes of learning today keeps the AI confusion away 🧠",
        "Your brain called — it wants more AI facts! ⚡",
        "Quick lesson? It only takes 2 minutes! 🎯",
        "Time to level up your AI knowledge! 🚀",
        "Your daily AI lesson awaits! 📚",
        "Stay curious — learn something new about AI today! ✨",
        "AI is changing the world. Stay ahead of the curve! 🌍"
    ]

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - Schedule All Smart Notifications

    func scheduleSmartNotifications(for user: UserProfile) {
        cancelAll()

        // 1. Streak at Risk — evening reminder if no activity today
        scheduleStreakReminder(streak: user.currentStreak)

        // 2. Daily Challenge — morning nudge
        if !user.hasCompletedDailyChallenge {
            scheduleDailyChallengeReminder()
        }

        // 3. Inactivity Nudge — if user hasn't opened app in 2 days
        scheduleInactivityNudge()

        // 4. Weekly Report — Sunday evening
        scheduleWeeklyReport(xp: user.totalXP, level: user.currentLevel)

        // 5. Hearts Refilled — next day at 9 AM
        if user.hearts < 5 {
            scheduleHeartsRefilled()
        }
    }

    // MARK: - Streak Reminder (8 PM daily)

    func scheduleStreakReminder(streak: Int) {
        guard streak > 0 else { return }

        let message = String(format: streakMessages.randomElement()!, streak)

        let content = UNMutableNotificationContent()
        content.title = "Streak Alert! 🔥"
        content.body = message
        content.sound = .default
        content.badge = 1

        // Trigger at 8 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.streakAtRisk, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily Challenge Reminder (9 AM)

    func scheduleDailyChallengeReminder() {
        let message = challengeMessages.randomElement()!

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = message
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.dailyChallenge, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Inactivity Nudge (48 hours from now)

    func scheduleInactivityNudge() {
        let message = comeBackMessages.randomElement()!

        let content = UNMutableNotificationContent()
        content.title = "We Miss You! 🤖"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 48 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.inactivity, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Hearts Refilled (next day 9 AM)

    func scheduleHeartsRefilled() {
        let content = UNMutableNotificationContent()
        content.title = "Hearts Refilled! ❤️"
        content.body = "Your hearts are full again! Ready for more lessons?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        // Tomorrow
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            let tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            dateComponents.year = tomorrowComponents.year
            dateComponents.month = tomorrowComponents.month
            dateComponents.day = tomorrowComponents.day
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.heartsRefilled, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Duel Turn Notification

    func scheduleDuelTurnNotification(opponentName: String) {
        let content = UNMutableNotificationContent()
        content.title = "It's Your Turn! ⚔️"
        content.body = "\(opponentName) has answered — now show them what you know!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.duelTurn, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Weekly Report (Sunday 7 PM)

    func scheduleWeeklyReport(xp: Int, level: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Recap 📊"
        content.body = "You're Level \(level) with \(xp) total XP! See how you rank on the leaderboard."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.weeklyReport, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Legacy Support

    func scheduleReminders(at time: Date, days: [Int], streak: Int) {
        cancelAll()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        for day in days {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = day

            var message = generalMessages.randomElement() ?? generalMessages[0]
            if streak > 0 {
                message = "Don't break your \(streak)-day streak! Keep going! 🏔️"
            }

            let content = UNMutableNotificationContent()
            content.title = "Vizancia"
            content.body = message
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "reminder_\(day)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        scheduleReminders(at: {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components) ?? Date()
        }(), days: [1, 2, 3, 4, 5, 6, 7], streak: 0)
    }
}
