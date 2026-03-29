import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showPracticeMistakes = false
    @State private var showDailyChallenge = false
    @State private var showQuickPlay: LessonData?
    @State private var quickPlayCategory: CategoryData?
    @State private var showContinueLesson: LessonData?
    @State private var continueCategory: CategoryData?
    @State private var showCategoryDetail: CategoryData?

    private let provider = LessonContentProvider.shared

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Greeting
                    greetingBanner
                        .padding(.horizontal)

                    // Continue Learning
                    if let continueInfo = continueWhere {
                        continueCard(category: continueInfo.0, lesson: continueInfo.1)
                    }

                    // Stats Row
                    statsRow
                        .padding(.horizontal)

                    // Action Cards
                    HStack(spacing: 12) {
                        DailyGoalWidget(user: user)
                        if !user.hasCompletedDailyChallenge {
                            dailyChallengeCompact
                        }
                    }
                    .padding(.horizontal)

                    // Quick Play
                    quickPlayButton

                    // Practice Mistakes
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesCard
                    }

                    // Recommended
                    if let recommended = recommendedCategory {
                        recommendedCard(recommended)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Vizancia")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showPracticeMistakes) {
                PracticeMistakesView(user: user)
            }
            .fullScreenCover(isPresented: $showDailyChallenge) {
                DailyChallengeView(user: user)
            }
            .fullScreenCover(item: $showQuickPlay) { lesson in
                if let cat = quickPlayCategory {
                    LessonView(user: user, lesson: lesson, category: cat)
                }
            }
            .fullScreenCover(item: $showContinueLesson) { lesson in
                if let cat = continueCategory {
                    LessonView(user: user, lesson: lesson, category: cat)
                }
            }
            .sheet(item: $showCategoryDetail) { cat in
                CategoryDetailView(user: user, category: cat)
            }
        }
    }

    // MARK: - Greeting
    private var greetingBanner: some View {
        let name = user.userName.isEmpty ? user.name : user.userName
        let displayName = (name == "Learner" || name.isEmpty) ? "" : ", \(name)"
        let greeting: String = {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 { return "Good morning\(displayName)!" }
            if hour < 17 { return "Good afternoon\(displayName)!" }
            return "Good evening\(displayName)!"
        }()

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text("What shall we learn today?")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            if user.currentStreak > 0 {
                StreakBadge(streak: user.currentStreak)
            }
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(user.totalXP)", label: "XP", icon: "star.fill", color: .aiPrimary)
            Divider().frame(height: 30)
            statItem(value: "\(user.currentLevel)", label: "Level", icon: "trophy.fill", color: .aiWarning)
            Divider().frame(height: 30)
            statItem(value: "\(user.totalLessonsCompleted)", label: "Lessons", icon: "book.fill", color: .aiSuccess)
            Divider().frame(height: 30)
            HeartsDisplay(hearts: user.hearts, showTimer: true, heartsLastRefill: user.heartsLastRefill)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Continue Learning
    private var continueWhere: (CategoryData, LessonData)? {
        guard user.totalLessonsCompleted > 0 else { return nil }
        for cat in provider.allCategories {
            if isCategoryLocked(cat) { continue }
            let prog = user.categoryProgressList.first { $0.categoryId == cat.id }
            if prog?.isComplete ?? false { continue }
            if let nextLesson = cat.lessons.first(where: { lesson in
                !(prog?.completedLessonIds.contains(lesson.id) ?? false)
            }) {
                return (cat, nextLesson)
            }
        }
        return nil
    }

    private func continueCard(category: CategoryData, lesson: LessonData) -> some View {
        Button {
            continueCategory = category
            showContinueLesson = lesson
            HapticService.shared.mediumTap()
            SoundService.shared.play(.whoosh)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("CONTINUE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                    Text(lesson.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(category.name)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPrimary, Color.aiPrimary.opacity(0.8), Color.aiGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .aiPrimary.opacity(0.3), radius: 10, y: 5)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Daily Challenge Compact
    private var dailyChallengeCompact: some View {
        Button { showDailyChallenge = true } label: {
            VStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.aiWarning)
                Text("Daily")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text("+25 XP")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.aiWarning)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiWarning.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Quick Play
    private var quickPlayButton: some View {
        Button {
            startQuickPlay()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Play")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Jump into a random lesson")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "shuffle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiPrimaryGradient)
                    .shadow(color: .aiPrimary.opacity(0.3), radius: 8, y: 4)
            )
        }
        .padding(.horizontal)
    }

    private func startQuickPlay() {
        let unlocked = provider.allCategories.filter { !isCategoryLocked($0) }
        guard let cat = unlocked.randomElement() else { return }
        let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
        let incomplete = cat.lessons.first { lesson in
            !(progress?.completedLessonIds.contains(lesson.id) ?? false)
        }
        let lesson = incomplete ?? cat.lessons.randomElement()
        guard let selectedLesson = lesson else { return }
        quickPlayCategory = cat
        showQuickPlay = selectedLesson
        HapticService.shared.mediumTap()
        SoundService.shared.play(.whoosh)
    }

    // MARK: - Recommended
    private var recommendedCategory: CategoryData? {
        if user.totalLessonsCompleted == 0 {
            switch user.experienceLevel {
            case .beginner: return provider.category(byId: "ai_basics")
            case .familiar: return provider.category(byId: "generative_ai")
            case .regular: return provider.category(byId: "prompt_engineering")
            case .builder: return provider.category(byId: "ai_ethics")
            }
        }
        for cat in provider.allCategories {
            if !isCategoryLocked(cat) {
                let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
                if !(progress?.isComplete ?? false) {
                    return cat
                }
            }
        }
        return nil
    }

    private func recommendedCard(_ category: CategoryData) -> some View {
        Button { showCategoryDetail = category } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiPrimary.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(.aiPrimary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Recommended for You")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(category.name)
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.aiPrimary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiPrimary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.aiPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Practice Mistakes
    private var practiceMistakesCard: some View {
        Button { showPracticeMistakes = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiOrange.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.aiOrange)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Practice Mistakes")
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    Text("\(user.missedQuestionIds.count) questions to review")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.aiTextSecondary)
                    .font(.caption)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers
    private func isCategoryLocked(_ category: CategoryData) -> Bool {
        switch category.unlockRequirement {
        case .none:
            return false
        case .completeCategory(let id):
            return !(user.categoryProgressList.first { $0.categoryId == id }?.isComplete ?? false)
        case .completeCategoryMinimum(let id):
            let progress = user.categoryProgressList.first { $0.categoryId == id }
            return (progress?.completedLessonIds.count ?? 0) < 2
        }
    }
}
