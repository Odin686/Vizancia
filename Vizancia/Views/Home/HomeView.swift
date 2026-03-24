import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?
    @State private var xpFloatText = ""
    @State private var showXPFloat = false
    @State private var showPracticeMistakes = false

    private let provider = LessonContentProvider.shared
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Stats
                    headerSection
                    
                    // Daily Goal
                    DailyGoalWidget(user: user)
                        .padding(.horizontal)

                    // Practice Mistakes
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesCard
                    }

                    // Categories Grid
                    categoriesSection
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Vizancia")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { headerToolbar }
            .sheet(item: $showCategoryDetail) { cat in
                CategoryDetailView(user: user, category: cat)
            }
            .fullScreenCover(isPresented: $showPracticeMistakes) {
                PracticeMistakesView(user: user)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            XPProgressBar(
                currentXP: user.totalXP,
                progress: user.levelProgress,
                level: user.currentLevel
            )
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                HeartsDisplay(hearts: user.hearts, showTimer: true, heartsLastRefill: user.heartsLastRefill)
                Spacer()
                StreakBadge(streak: user.currentStreak)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var headerToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            LevelBadge(level: user.currentLevel, size: 34)
        }
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Learning Paths")
                .font(.aiTitle())
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ], spacing: 14) {
                ForEach(provider.allCategories) { category in
                    let locked = isCategoryLocked(category)
                    let progress = user.categoryProgressList.first { $0.categoryId == category.id }
                    CategoryCard(
                        category: category,
                        progress: progress,
                        isLocked: locked,
                        unlockHint: unlockHint(for: category)
                    ) {
                        showCategoryDetail = category
                    }
                }
            }
            .padding(.horizontal)
        }
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

    private func unlockHint(for category: CategoryData) -> String? {
        guard let requiredId = category.unlockRequirement.requiredCategoryId,
              let requiredCategory = provider.category(byId: requiredId) else { return nil }
        switch category.unlockRequirement {
        case .none:
            return nil
        case .completeCategory:
            return "Complete \(requiredCategory.name)"
        case .completeCategoryMinimum:
            return "Complete 2 lessons in \(requiredCategory.name)"
        }
    }
}
