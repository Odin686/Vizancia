import Foundation

struct AchievementData: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let condition: (UserProfile) -> Bool
    var progressInfo: ((UserProfile) -> (current: Int, target: Int))?
    
    static let all: [AchievementData] = [
        AchievementData(
            id: "first_steps",
            name: "First Steps",
            icon: "🌱",
            description: "Complete your first lesson",
            condition: { $0.totalLessonsCompleted >= 1 },
            progressInfo: { (current: min($0.totalLessonsCompleted, 1), target: 1) }
        ),
        AchievementData(
            id: "on_fire",
            name: "On Fire",
            icon: "🔥",
            description: "Achieve a 3-day streak",
            condition: { $0.currentStreak >= 3 },
            progressInfo: { (current: min($0.currentStreak, 3), target: 3) }
        ),
        AchievementData(
            id: "dedicated_learner",
            name: "Dedicated Learner",
            icon: "🏔️",
            description: "Achieve a 7-day streak",
            condition: { $0.currentStreak >= 7 },
            progressInfo: { (current: min($0.currentStreak, 7), target: 7) }
        ),
        AchievementData(
            id: "perfectionist",
            name: "Perfectionist",
            icon: "💯",
            description: "Get a perfect score on 5 lessons",
            condition: { $0.perfectLessonIDs.count >= 5 },
            progressInfo: { (current: min($0.perfectLessonIDs.count, 5), target: 5) }
        ),
        AchievementData(
            id: "ai_basics_master",
            name: "AI Basics Master",
            icon: "🧠",
            description: "Complete all AI Basics lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "ai_basics" })?.isComplete ?? false },
            progressInfo: { (current: $0.categoryProgressList.first(where: { $0.categoryId == "ai_basics" })?.completedLessonIds.count ?? 0, target: LessonContentProvider.shared.category(byId: "ai_basics")?.lessonCount ?? 6) }
        ),
        AchievementData(
            id: "speed_demon",
            name: "Speed Demon",
            icon: "⚡",
            description: "Score 15+ in Speed Round",
            condition: { ($0.gameHighScores["speedRound"] ?? 0) >= 15 },
            progressInfo: { (current: min($0.gameHighScores["speedRound"] ?? 0, 15), target: 15) }
        ),
        AchievementData(
            id: "sharpshooter",
            name: "Sharpshooter",
            icon: "🎯",
            description: "Answer 100 questions correctly",
            condition: { $0.totalCorrectAnswers >= 100 },
            progressInfo: { (current: min($0.totalCorrectAnswers, 100), target: 100) }
        ),
        AchievementData(
            id: "well_rounded",
            name: "Well-Rounded",
            icon: "🌍",
            description: "Complete at least 1 lesson in every category",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.completedLessonIds.isEmpty == false
                }
            },
            progressInfo: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                let started = allCats.filter { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.completedLessonIds.isEmpty == false
                }.count
                return (current: started, target: allCats.count)
            }
        ),
        AchievementData(
            id: "half_way",
            name: "Halfway There",
            icon: "🏆",
            description: "Complete 30 lessons",
            condition: { $0.totalLessonsCompleted >= 30 },
            progressInfo: { (current: min($0.totalLessonsCompleted, 30), target: 30) }
        ),
        AchievementData(
            id: "graduate",
            name: "Graduate",
            icon: "🎓",
            description: "Complete all categories",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.isComplete ?? false
                }
            },
            progressInfo: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                let done = allCats.filter { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.isComplete ?? false
                }.count
                return (current: done, target: allCats.count)
            }
        ),
        AchievementData(
            id: "game_night",
            name: "Game Night",
            icon: "🕹️",
            description: "Play 10 mini-games",
            condition: { $0.gamesPlayed >= 10 },
            progressInfo: { (current: min($0.gamesPlayed, 10), target: 10) }
        ),
        AchievementData(
            id: "bookworm",
            name: "Bookworm",
            icon: "📚",
            description: "Complete 50 total lessons",
            condition: { $0.totalLessonsCompleted >= 50 },
            progressInfo: { (current: min($0.totalLessonsCompleted, 50), target: 50) }
        ),
        AchievementData(
            id: "ethics_expert",
            name: "Ethics Expert",
            icon: "🔬",
            description: "Complete all AI Ethics lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "ai_ethics" })?.isComplete ?? false },
            progressInfo: { (current: $0.categoryProgressList.first(where: { $0.categoryId == "ai_ethics" })?.completedLessonIds.count ?? 0, target: LessonContentProvider.shared.category(byId: "ai_ethics")?.lessonCount ?? 6) }
        ),
        AchievementData(
            id: "survivor",
            name: "Survivor",
            icon: "❤️",
            description: "Complete 10 lessons",
            condition: { $0.totalLessonsCompleted >= 10 },
            progressInfo: { (current: min($0.totalLessonsCompleted, 10), target: 10) }
        ),
        AchievementData(
            id: "century_club",
            name: "Century Club",
            icon: "🎉",
            description: "Earn a 100-day streak",
            condition: { $0.currentStreak >= 100 },
            progressInfo: { (current: min($0.currentStreak, 100), target: 100) }
        ),
        AchievementData(
            id: "rising_star",
            name: "Rising Star",
            icon: "⭐",
            description: "Reach Level 5",
            condition: { $0.currentLevel >= 5 },
            progressInfo: { (current: min($0.currentLevel, 5), target: 5) }
        ),
        AchievementData(
            id: "to_the_moon",
            name: "To the Moon",
            icon: "🚀",
            description: "Reach Level 10",
            condition: { $0.currentLevel >= 10 },
            progressInfo: { (current: min($0.currentLevel, 10), target: 10) }
        ),
        AchievementData(
            id: "puzzle_master",
            name: "Puzzle Master",
            icon: "🧩",
            description: "Score 10+ in Buzzword Buster",
            condition: { ($0.gameHighScores["buzzwordBuster"] ?? 0) >= 10 },
            progressInfo: { (current: min($0.gameHighScores["buzzwordBuster"] ?? 0, 10), target: 10) }
        ),
        AchievementData(
            id: "prompt_pro",
            name: "Prompt Pro",
            icon: "🤖",
            description: "Complete all Prompt Engineering lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "prompt_engineering" })?.isComplete ?? false },
            progressInfo: { (current: $0.categoryProgressList.first(where: { $0.categoryId == "prompt_engineering" })?.completedLessonIds.count ?? 0, target: LessonContentProvider.shared.category(byId: "prompt_engineering")?.lessonCount ?? 6) }
        ),
        AchievementData(
            id: "ai_visionary",
            name: "AI Visionary",
            icon: "🌟",
            description: "Reach Level 12 (max level)",
            condition: { $0.currentLevel >= 12 },
            progressInfo: { (current: min($0.currentLevel, 12), target: 12) }
        ),

        // MARK: - Duel Achievements

        AchievementData(
            id: "first_blood",
            name: "First Blood",
            icon: "⚔️",
            description: "Win your first duel",
            condition: { $0.duelWins >= 1 },
            progressInfo: { (current: min($0.duelWins, 1), target: 1) }
        ),
        AchievementData(
            id: "duel_streak_3",
            name: "Hat Trick",
            icon: "🎩",
            description: "Win 3 duels",
            condition: { $0.duelWins >= 3 },
            progressInfo: { (current: min($0.duelWins, 3), target: 3) }
        ),
        AchievementData(
            id: "duel_streak_5",
            name: "AI Gladiator",
            icon: "🛡️",
            description: "Win 5 duels",
            condition: { $0.duelWins >= 5 },
            progressInfo: { (current: min($0.duelWins, 5), target: 5) }
        ),
        AchievementData(
            id: "duel_streak_10",
            name: "Knowledge Knight",
            icon: "🏰",
            description: "Win 10 duels",
            condition: { $0.duelWins >= 10 },
            progressInfo: { (current: min($0.duelWins, 10), target: 10) }
        ),
        AchievementData(
            id: "duel_streak_20",
            name: "Quiz Champion",
            icon: "🏆",
            description: "Win 20 duels",
            condition: { $0.duelWins >= 20 },
            progressInfo: { (current: min($0.duelWins, 20), target: 20) }
        ),
        AchievementData(
            id: "duel_streak_35",
            name: "Grand Master",
            icon: "👑",
            description: "Win 35 duels",
            condition: { $0.duelWins >= 35 },
            progressInfo: { (current: min($0.duelWins, 35), target: 35) }
        ),
        AchievementData(
            id: "duel_streak_50",
            name: "Duel Legend",
            icon: "🐉",
            description: "Win 50 duels",
            condition: { $0.duelWins >= 50 },
            progressInfo: { (current: min($0.duelWins, 50), target: 50) }
        ),
        AchievementData(
            id: "duel_streak_100",
            name: "Legendary Duelist",
            icon: "💎",
            description: "Win 100 duels",
            condition: { $0.duelWins >= 100 },
            progressInfo: { (current: min($0.duelWins, 100), target: 100) }
        ),
    ]
}
