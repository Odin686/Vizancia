import SwiftUI

struct LearnView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?
    @State private var filter: LearnFilter = .all

    private let provider = LessonContentProvider.shared

    enum LearnFilter: String, CaseIterable {
        case all = "All"
        case started = "Started"
        case new = "New"
        case complete = "Complete"
    }

    private var filteredCategories: [CategoryData] {
        switch filter {
        case .all:
            return provider.allCategories
        case .started:
            return provider.allCategories.filter { cat in
                let prog = user.categoryProgressList.first { $0.categoryId == cat.id }
                let started = (prog?.completedLessonIds.count ?? 0) > 0
                let complete = prog?.isComplete ?? false
                return started && !complete
            }
        case .new:
            return provider.allCategories.filter { cat in
                let prog = user.categoryProgressList.first { $0.categoryId == cat.id }
                return (prog?.completedLessonIds.count ?? 0) == 0
            }
        case .complete:
            return provider.allCategories.filter { cat in
                user.categoryProgressList.first { $0.categoryId == cat.id }?.isComplete ?? false
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Today's Pick
                    if let pick = todaysPickCategory, filter == .all {
                        todaysPickCard(pick)
                    }

                    // Filter chips
                    filterBar
                        .padding(.horizontal)

                    // Category list
                    ForEach(filteredCategories) { category in
                        let locked = isCategoryLocked(category)
                        let progress = user.categoryProgressList.first { $0.categoryId == category.id }
                        fullCategoryCard(category: category, progress: progress, isLocked: locked)
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

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(LearnFilter.allCases, id: \.self) { f in
                Button {
                    withAnimation(.spring(response: 0.3)) { filter = f }
                    HapticService.shared.lightTap()
                } label: {
                    Text(f.rawValue)
                        .font(.system(size: 13, weight: filter == f ? .bold : .medium, design: .rounded))
                        .foregroundColor(filter == f ? .white : .aiTextSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(filter == f ? Color.aiPrimary : Color.aiCard)
                        )
                }
            }
            Spacer()
        }
    }

    // MARK: - Full Category Card
    private func fullCategoryCard(category: CategoryData, progress: CategoryProgress?, isLocked: Bool) -> some View {
        let completedLessons = progress?.completedLessonIds.count ?? 0
        let totalLessons = category.lessons.count
        let progressFraction: Double = totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
        let isComplete = completedLessons == totalLessons && totalLessons > 0
        let isNew = completedLessons == 0 && !isLocked
        let color = categoryColor(for: category.colorName)

        return Button { showCategoryDetail = category } label: {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isLocked ? Color.aiTextSecondary.opacity(0.1) : color)
                        .frame(width: 52, height: 52)
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isLocked ? .aiTextSecondary : .white)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(category.name)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(isLocked ? .aiTextSecondary : .aiTextPrimary)
                            .lineLimit(1)
                        if isNew {
                            Text("NEW")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(color))
                        }
                    }
                    Text(category.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                        .lineLimit(1)

                    if isLocked {
                        if let hint = unlockHint(for: category) {
                            Label(hint, systemImage: "lock.fill")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                        }
                    } else if isComplete {
                        masteryLabel(category: category, progress: progress)
                    } else {
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color.opacity(0.15))
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color)
                                    .frame(width: geo.size.width * progressFraction)
                            }
                        }
                        .frame(height: 5)
                    }
                }

                Spacer()

                // Right side
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.aiTextSecondary)
                } else if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.aiSuccess)
                } else {
                    VStack(spacing: 1) {
                        Text("\(completedLessons)/\(totalLessons)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(color)
                        Text("lessons")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isComplete ? color.opacity(0.3) : Color.clear,
                        lineWidth: isComplete ? 1.5 : 0
                    )
            )
            .opacity(isLocked ? 0.6 : 1)
        }
        .disabled(isLocked)
        .padding(.horizontal)
    }

    // MARK: - Mastery Label
    private func masteryLabel(category: CategoryData, progress: CategoryProgress?) -> some View {
        let accuracy = user.categoryAccuracy(for: category.id)
        let stars = progress?.lessonStars ?? [:]
        let totalStars = stars.values.reduce(0, +)
        let maxStars = category.lessons.count * 3
        let starRatio = maxStars > 0 ? Double(totalStars) / Double(maxStars) : 0

        let tier: String
        let tierColor: Color
        if starRatio >= 0.95 && accuracy >= 0.9 {
            tier = "Gold"
            tierColor = Color(red: 1.0, green: 0.84, blue: 0.0)
        } else if starRatio >= 0.7 && accuracy >= 0.8 {
            tier = "Silver"
            tierColor = Color(red: 0.6, green: 0.65, blue: 0.7)
        } else {
            tier = "Bronze"
            tierColor = Color(red: 0.8, green: 0.5, blue: 0.2)
        }

        return HStack(spacing: 4) {
            Image(systemName: tier == "Gold" ? "trophy.fill" : "medal.fill")
                .font(.system(size: 10))
                .foregroundColor(tierColor)
            Text(tier)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(tierColor)
        }
    }

    // MARK: - Today's Pick
    private var todaysPickCategory: CategoryData? {
        let unlocked = provider.allCategories.filter { !isCategoryLocked($0) }
        let incomplete = unlocked.filter { cat in
            !(user.categoryProgressList.first { $0.categoryId == cat.id }?.isComplete ?? false)
        }
        guard !incomplete.isEmpty else { return nil }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return incomplete[dayIndex % incomplete.count]
    }

    private func todaysPickCard(_ category: CategoryData) -> some View {
        Button { showCategoryDetail = category } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TODAY'S PICK")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1.5)
                    Spacer()
                    Image(systemName: "sparkles")
                        .foregroundColor(.white.opacity(0.6))
                }
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image(systemName: category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(category.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(category.description)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                HStack {
                    let prog = user.categoryProgressList.first { $0.categoryId == category.id }
                    let done = prog?.completedLessonIds.count ?? 0
                    Text("\(done)/\(category.lessons.count) lessons")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("Start Learning")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color.aiPrimary, Color.aiGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .aiPrimary.opacity(0.25), radius: 10, y: 5)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers
    private func isCategoryLocked(_ category: CategoryData) -> Bool {
        switch category.unlockRequirement {
        case .none: return false
        case .completeCategory(let id):
            return !(user.categoryProgressList.first { $0.categoryId == id }?.isComplete ?? false)
        case .completeCategoryMinimum(let id):
            return (user.categoryProgressList.first { $0.categoryId == id }?.completedLessonIds.count ?? 0) < 2
        }
    }

    private func unlockHint(for category: CategoryData) -> String? {
        guard let requiredId = category.unlockRequirement.requiredCategoryId,
              let requiredCategory = provider.category(byId: requiredId) else { return nil }
        switch category.unlockRequirement {
        case .none: return nil
        case .completeCategory: return "Complete \(requiredCategory.name)"
        case .completeCategoryMinimum: return "Complete 2 lessons in \(requiredCategory.name)"
        }
    }

    private func categoryColor(for colorName: String) -> Color {
        switch colorName {
        case "aiPrimary": return .aiPrimary
        case "aiSecondary": return .aiSecondary
        case "aiOrange": return .aiOrange
        case "aiRed": return .aiError
        case "aiGreen": return .aiSuccess
        case "aiTeal": return .aiSecondary
        case "aiIndigo": return .aiPrimary
        case "aiBrown": return .aiOrange
        case "aiCyan": return .aiSecondary
        case "aiPink": return .aiError
        case "aiBlue": return .aiPrimary
        case "aiPurple": return .aiPrimary
        default: return .aiPrimary
        }
    }
}
