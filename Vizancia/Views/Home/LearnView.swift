import SwiftUI

struct LearnView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?

    private let provider = LessonContentProvider.shared

    private let tracks: [(name: String, icon: String, ids: [String])] = [
        ("Start Here", "star.fill", ["ai_basics", "how_ai_learns", "ai_history"]),
        ("Level Up", "arrow.up.circle.fill", ["generative_ai", "prompt_engineering", "ai_at_work"]),
        ("Go Deeper", "magnifyingglass", ["ai_vocabulary", "ai_under_hood", "ai_tools"]),
        ("Explore", "globe.americas.fill", ["ai_ethics", "ai_healthcare", "ai_creative_arts", "future_of_ai"]),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(tracks, id: \.name) { track in
                        trackSection(track)
                    }
                }
                .padding(.bottom, 30)
                .padding(.top, 8)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $showCategoryDetail) { cat in
                CategoryDetailView(user: user, category: cat)
            }
        }
    }

    private func trackSection(_ track: (name: String, icon: String, ids: [String])) -> some View {
        let categories = track.ids.compactMap { id in provider.category(byId: id) }
        let completedCount = categories.filter { cat in
            user.categoryProgressList.first { $0.categoryId == cat.id }?.isComplete ?? false
        }.count
        let allComplete = completedCount == categories.count && categories.count > 0

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: allComplete ? "checkmark.circle.fill" : track.icon)
                    .font(.system(size: 14))
                    .foregroundColor(allComplete ? .aiSuccess : .aiPrimary)
                Text(track.name)
                    .font(.aiTitle())
                Text("\(completedCount)/\(categories.count)")
                    .font(.aiCaption())
                    .foregroundColor(allComplete ? .aiSuccess : .aiTextSecondary)
                if allComplete {
                    Text("Complete!")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.aiSuccess)
                }
                Spacer()
            }
            .padding(.horizontal)

            if !allComplete {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(categories) { category in
                            let locked = isCategoryLocked(category)
                            let progress = user.categoryProgressList.first { $0.categoryId == category.id }
                            CategoryCard(
                                category: category,
                                progress: progress,
                                isLocked: locked,
                                unlockHint: unlockHint(for: category),
                                categoryAccuracy: user.categoryAccuracy(for: category.id)
                            ) {
                                showCategoryDetail = category
                            }
                            .frame(width: 170)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

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
