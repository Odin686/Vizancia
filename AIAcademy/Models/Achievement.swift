import Foundation

struct AchievementData: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let condition: (UserProfile) -> Bool
    
    static let all: [AchievementData] = [
        AchievementData(
            id: "first_steps",
            name: "First Steps",
            icon: "🌱",
            description: "Complete your first lesson",
            condition: { $0.totalLessonsCompleted >= 1 }
        ),
        AchievementData(
            id: "on_fire",
            name: "On Fire",
            icon: "🔥",
            description: "Achieve a 3-day streak",
            condition: { $0.currentStreak >= 3 }
        ),
        AchievementData(
            id: "dedicated_learner",
            name: "Dedicated Learner",
            icon: "🏔️",
            description: "Achieve a 7-day streak",
            condition: { $0.currentStreak >= 7 }
        ),
        AchievementData(
            id: "perfectionist",
            name: "Perfectionist",
            icon: "💯",
            description: "Get a perfect score on 5 lessons",
            condition: { $0.perfectLessonIDs.count >= 5 }
        ),
        AchievementData(
            id: "ai_basics_master",
            name: "AI Basics Master",
            icon: "🧠",
            description: "Complete all AI Basics lessons",
            condition: { $0.categoryProgressData["ai_basics"]?.isCompleted ?? false }
        ),
        AchievementData(
            id: "speed_demon",
            name: "Speed Demon",
            icon: "⚡",
            description: "Complete Speed Round under 60 seconds",
            condition: { ($0.gameHighScores["speedRound_time"] ?? Int.max) < 60 }
        ),
        AchievementData(
            id: "sharpshooter",
            name: "Sharpshooter",
            icon: "🎯",
            description: "Answer 20 questions correctly in a row",
            condition: { $0.consecutiveCorrect >= 20 }
        ),
        AchievementData(
            id: "well_rounded",
            name: "Well-Rounded",
            icon: "🌍",
            description: "Complete at least 1 lesson in every category",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { cat in
                    (profile.categoryProgressData[cat.id]?.lessonsCompleted ?? 0) >= 1
                }
            }
        ),
        AchievementData(
            id: "crown_collector",
            name: "Crown Collector",
            icon: "🏆",
            description: "Earn 5 crowns in any category",
            condition: { $0.categoryProgressData.values.contains(where: { $0.crownLevel >= 5 }) }
        ),
        AchievementData(
            id: "graduate",
            name: "Graduate",
            icon: "🎓",
            description: "Complete all categories",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { profile.categoryProgressData[$0.id]?.isCompleted ?? false }
            }
        ),
        AchievementData(
            id: "game_night",
            name: "Game Night",
            icon: "🕹️",
            description: "Play all 5 mini-games",
            condition: { $0.gamesPlayedByType.count >= 5 }
        ),
        AchievementData(
            id: "bookworm",
            name: "Bookworm",
            icon: "📚",
            description: "Complete 50 total lessons",
            condition: { $0.totalLessonsCompleted >= 50 }
        ),
        AchievementData(
            id: "ethics_expert",
            name: "Ethics Expert",
            icon: "🔬",
            description: "Complete AI Ethics category with all crowns",
            condition: { ($0.categoryProgressData["ai_ethics"]?.crownLevel ?? 0) >= 5 }
        ),
        AchievementData(
            id: "survivor",
            name: "Survivor",
            icon: "❤️",
            description: "Complete a lesson with only 1 heart remaining",
            condition: { $0.hasAchievement("survivor") }
        ),
        AchievementData(
            id: "century_club",
            name: "Century Club",
            icon: "🎉",
            description: "Earn a 100-day streak",
            condition: { $0.currentStreak >= 100 }
        ),
        AchievementData(
            id: "rising_star",
            name: "Rising Star",
            icon: "⭐",
            description: "Reach Level 5",
            condition: { $0.currentLevel >= 5 }
        ),
        AchievementData(
            id: "to_the_moon",
            name: "To the Moon",
            icon: "🚀",
            description: "Reach Level 10",
            condition: { $0.currentLevel >= 10 }
        ),
        AchievementData(
            id: "puzzle_master",
            name: "Puzzle Master",
            icon: "🧩",
            description: "Win Match Pairs 10 times without mistakes",
            condition: { ($0.gameHighScores["matchPairsPerfect"] ?? 0) >= 10 }
        ),
        AchievementData(
            id: "prompt_pro",
            name: "Prompt Pro",
            icon: "🤖",
            description: "Complete all Prompt Engineering lessons",
            condition: { $0.categoryProgressData["prompt_engineering"]?.isCompleted ?? false }
        ),
        AchievementData(
            id: "ai_visionary",
            name: "AI Visionary",
            icon: "🌟",
            description: "Reach Level 12 (max level)",
            condition: { $0.currentLevel >= 12 }
        ),
    ]
}
