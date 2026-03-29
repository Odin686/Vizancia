import SwiftUI

struct ProfileView: View {
    @Bindable var user: UserProfile
    @State private var showResetAlert = false
    @State private var selectedSection = 0

    private let provider = LessonContentProvider.shared

    private var displayName: String {
        if !user.userName.isEmpty { return user.userName }
        if !user.name.isEmpty && user.name != "Learner" { return user.name }
        return "AI Learner"
    }

    private var totalLessonsAvail: Int { provider.allCategories.flatMap(\.lessons).count }
    private var completedCategories: Int { user.categoryProgressList.filter(\.isComplete).count }
    private var overallAccuracy: Int {
        user.totalQuestionsAnswered > 0 ? (user.totalCorrectAnswers * 100) / user.totalQuestionsAnswered : 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        miniStat(value: formatNumber(user.totalXP), label: "XP", color: .aiPrimary)
                        miniStat(value: "\(user.currentStreak)", label: "Streak", color: .aiOrange)
                        miniStat(value: "\(overallAccuracy)%", label: "Accuracy", color: .aiSecondary)
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        miniStat(value: "\(user.totalLessonsCompleted)", label: "Lessons", color: .aiSuccess)
                        miniStat(value: "\(completedCategories)", label: "Categories", color: .aiWarning)
                        miniStat(value: "\(user.gamesPlayed)", label: "Games", color: .aiError)
                    }
                    .padding(.horizontal)

                    // Achievements
                    achievementsSection

                    // Activity Heatmap
                    streakCalendar

                    // Settings
                    settingsSection

                    // About
                    aboutSection

                    // Reset
                    resetSection
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    user.totalXP = 0
                    user.currentLevel = 1
                    user.currentStreak = 0
                    user.longestStreak = 0
                    user.hearts = 5
                    user.totalLessonsCompleted = 0
                    user.totalCorrectAnswers = 0
                    user.totalQuestionsAnswered = 0
                    user.gamesPlayed = 0
                    user.categoryProgressList = []
                    user.unlockedAchievementIds = []
                    user.gameHighScores = [:]
                    user.todayXP = 0
                    user.activeDays = []
                    user.missedQuestionIds = []
                }
            } message: {
                Text("This will erase all your progress, XP, achievements, and stats. This cannot be undone.")
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            LevelBadge(level: user.currentLevel, size: 64)
            Text(displayName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            let levelDef = LevelDefinition.all.first { $0.level == user.currentLevel }
            Text(levelDef?.title ?? "AI Novice")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
            XPProgressBar(currentXP: user.totalXP, progress: user.levelProgress, level: user.currentLevel)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Mini Stat
    private func miniStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
    }

    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.aiTitle())
                Text("\(user.unlockedAchievementIds.count)/\(AchievementData.all.count)")
                    .font(.aiCaption())
                    .foregroundColor(.aiTextSecondary)
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementData.all) { achievement in
                        let unlocked = user.unlockedAchievementIds.contains(achievement.id)
                        let progress = achievement.progressInfo?(user)
                        VStack(spacing: 4) {
                            Text(achievement.icon)
                                .font(.system(size: 28))
                                .grayscale(unlocked ? 0 : 1)
                                .opacity(unlocked ? 1 : 0.4)
                            Text(achievement.name)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary)
                                .lineLimit(1)
                            if !unlocked, let p = progress, p.target > 0 {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.aiPrimary.opacity(0.12))
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.aiPrimary.opacity(0.5))
                                            .frame(width: geo.size.width * min(Double(p.current) / Double(p.target), 1.0))
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal, 6)
                                Text("\(p.current)/\(p.target)")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.aiTextSecondary)
                            } else if unlocked {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.aiSuccess)
                            }
                        }
                        .frame(width: 80, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(unlocked ? Color.aiPrimary.opacity(0.08) : Color.aiCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(unlocked ? Color.aiPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Streak Calendar
    private var streakCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.aiTitle())
                .padding(.horizontal)

            let days = Date().last90Days()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(days, id: \.self) { day in
                    let active = user.activeDays.contains(day.formatted(.dateTime.year().month().day()))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(active ? Color.aiSuccess : Color.aiSuccess.opacity(0.1))
                        .frame(height: 14)
                }
            }
            .padding(.horizontal)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        )
        .padding(.horizontal)
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.aiTitle())
                .padding(.horizontal)

            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        Label("Name", systemImage: "person")
                        Spacer()
                        TextField("Your name", text: $user.userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.aiTextSecondary)
                            .onChange(of: user.userName) { _, newValue in
                                user.name = newValue
                            }
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Picker("Daily Goal", selection: $user.dailyGoalTier) {
                        ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                            Text("\(tier.rawValue.capitalized) (\(tier.xpTarget) XP)").tag(tier)
                        }
                    }
                    .onChange(of: user.dailyGoalTier) { _, new in
                        user.dailyXPGoal = new.xpTarget
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Toggle(isOn: $user.soundEnabled) {
                        Label("Sounds", systemImage: "speaker.wave.2.fill")
                    }
                    .onChange(of: user.soundEnabled) { _, new in
                        SoundService.shared.isEnabled = new
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Toggle(isOn: $user.hapticsEnabled) {
                        Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .onChange(of: user.hapticsEnabled) { _, new in
                        HapticService.shared.isEnabled = new
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Toggle(isOn: $user.notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    .onChange(of: user.notificationsEnabled) { _, new in
                        if new { NotificationService.shared.requestPermission { _ in } }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))
            .padding(.horizontal)
        }
    }

    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }

    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.aiTitle())
                .padding(.horizontal)

            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("2.0.0").foregroundColor(.aiTextSecondary)
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Link(destination: URL(string: "https://odin686.github.io/Vizancia/privacy-policy.html")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.aiTextSecondary)
                        }
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Link(destination: URL(string: "https://odin686.github.io/Vizancia/terms-of-service.html")!) {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.aiTextSecondary)
                        }
                    }
                }
                Divider().padding(.leading, 50)
                settingsRow {
                    Button {
                        if let url = URL(string: "mailto:info@vizancia.ca") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Label("Contact Support", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.aiTextSecondary)
                        }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))
            .padding(.horizontal)
        }
    }

    // MARK: - Reset
    private var resetSection: some View {
        Button(role: .destructive) {
            showResetAlert = true
        } label: {
            HStack {
                Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                    .foregroundColor(.aiError)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))
        }
        .padding(.horizontal)
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000.0) }
        return "\(n)"
    }
}
