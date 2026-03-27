import SwiftUI

struct OnboardingView: View {
    @Bindable var user: UserProfile
    @State private var currentPage = 0
    @State private var selectedGoal: DailyGoalTier = .casual
    @State private var enableNotifications = true
    @State private var nameText = ""
    @State private var selectedExperience: UserProfile.ExperienceLevel = .beginner
    @State private var selectedRole: UserProfile.UserRole = .curious
    @State private var selectedOccupation = ""

    private let totalPages = 7

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                nameInputPage.tag(1)
                experiencePage.tag(2)
                whyHerePage.tag(3)
                occupationPage.tag(4)
                goalPage.tag(5)
                readyPage.tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Page dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? Color.aiPrimary : Color.aiPrimary.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .scaleEffect(i == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Page 1: Welcome with Viz
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.aiPrimary)
            Text("Welcome to\nVizancia")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
            Text("Learn AI the fun way.\nLet's get to know you!")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            nextButton { withAnimation { currentPage = 1 } }
        }
        .padding(30)
    }

    // MARK: - Page 2: Name
    private var nameInputPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.aiPrimary)
            Text("What should I call you?")
                .font(.aiTitle())
                .foregroundColor(.aiTextPrimary)

            TextField("Your name", text: $nameText)
                .font(.aiBody())
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.aiPrimary.opacity(0.3), lineWidth: 1)
                        )
                )
                .autocorrectionDisabled()

            Spacer()
            nextButton {
                user.userName = nameText.isEmpty ? "Learner" : nameText
                user.name = user.userName
                withAnimation { currentPage = 2 }
            }
        }
        .padding(30)
    }

    // MARK: - Page 3: Experience Level
    private var experiencePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.aiPrimary)
            Text("Have you used AI before?")
                .font(.aiTitle())
            Text("Like ChatGPT, Siri, or other AI tools")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)

            VStack(spacing: 10) {
                experienceOption(.beginner, emoji: "🌱", label: "Never used AI", detail: "I'm completely new to this")
                experienceOption(.familiar, emoji: "👋", label: "A few times", detail: "I've tried ChatGPT or similar")
                experienceOption(.regular, emoji: "💻", label: "I use AI regularly", detail: "It's part of my routine")
                experienceOption(.builder, emoji: "🛠️", label: "I build with AI", detail: "I create AI apps or models")
            }

            Spacer()
            nextButton {
                user.experienceLevel = selectedExperience
                withAnimation { currentPage = 3 }
            }
        }
        .padding(30)
    }

    // MARK: - Page 4: Why Are You Here?
    private var whyHerePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.aiPrimary)
            Text("Why are you here?")
                .font(.aiTitle())
            Text("This helps me personalize your journey")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)

            VStack(spacing: 10) {
                roleOption(.curious, emoji: "🔍", label: "Just curious", detail: "I want to understand AI better")
                roleOption(.student, emoji: "📚", label: "School or study", detail: "Learning for class or self-study")
                roleOption(.professional, emoji: "💼", label: "Career growth", detail: "AI skills for my job or career")
                roleOption(.fun, emoji: "🎮", label: "Just for fun", detail: "I like learning new things")
            }

            Spacer()
            nextButton {
                user.userRole = selectedRole
                withAnimation { currentPage = 4 }
            }
        }
        .padding(30)
    }

    // MARK: - Page 5: Occupation
    private var occupationPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.aiPrimary)
            Text("What describes you best?")
                .font(.aiTitle())

            let occupations = [
                ("🎒", "Student"),
                ("👩‍💻", "Working professional"),
                ("🎓", "Teacher / Educator"),
                ("🧒", "Young learner"),
                ("🔄", "Career changer"),
                ("🧠", "Lifelong learner"),
            ]

            VStack(spacing: 10) {
                ForEach(occupations, id: \.1) { emoji, label in
                    selectionRow(
                        emoji: emoji,
                        label: label,
                        isSelected: selectedOccupation == label
                    ) {
                        selectedOccupation = label
                        HapticService.shared.lightTap()
                    }
                }
            }

            Spacer()
            nextButton { withAnimation { currentPage = 5 } }
        }
        .padding(30)
    }

    // MARK: - Page 6: Daily Goal
    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.aiPrimary)
            Text("Set Your Daily Goal")
                .font(.aiTitle())
            Text(vizGoalMessage)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                    Button {
                        selectedGoal = tier
                        HapticService.shared.lightTap()
                    } label: {
                        HStack {
                            Text(tier.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.rawValue.capitalized)
                                    .font(.aiHeadline())
                                    .foregroundColor(.aiTextPrimary)
                                Text("\(tier.xpTarget) XP per day")
                                    .font(.aiCaption())
                                    .foregroundColor(.aiTextSecondary)
                            }
                            Spacer()
                            if selectedGoal == tier {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.aiSuccess)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedGoal == tier ? Color.aiSuccess.opacity(0.08) : Color.aiCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedGoal == tier ? Color.aiSuccess : Color.aiTextSecondary.opacity(0.15), lineWidth: selectedGoal == tier ? 2 : 1)
                                )
                        )
                    }
                }
            }

            Spacer()
            nextButton {
                user.dailyGoalTier = selectedGoal
                user.dailyXPGoal = selectedGoal.xpTarget
                if enableNotifications {
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            NotificationService.shared.scheduleDailyReminder(hour: 19, minute: 0)
                        }
                    }
                }
                withAnimation { currentPage = 6 }
            }
        }
        .padding(30)
    }

    // MARK: - Page 7: Ready
    private var readyPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "rocket.fill")
                .font(.system(size: 80))
                .foregroundColor(.aiPrimary)
            Text(vizReadyMessage)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
            Text(vizReadySubtitle)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)

            // Notification toggle
            Toggle(isOn: $enableNotifications) {
                Label("Daily Reminders", systemImage: "bell.badge.fill")
                    .font(.aiHeadline())
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))

            Spacer()
            Button {
                user.notificationsEnabled = enableNotifications
                withAnimation(.spring(response: 0.4)) {
                    user.onboardingCompleted = true
                }
                HapticService.shared.success()
            } label: {
                Text("Let's Go!")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.aiPrimaryGradient))
            }
        }
        .padding(30)
    }

    // MARK: - Contextual Messages
    private var vizGoalMessage: String {
        switch selectedExperience {
        case .beginner: return "Since you're new to AI, I'd suggest starting casual!"
        case .familiar: return "You've got some experience — regular is a great pace!"
        case .regular: return "You're already using AI — let's go serious!"
        case .builder: return "A builder! Intense mode will keep you challenged."
        }
    }

    private var vizReadyMessage: String {
        let name = nameText.isEmpty ? "friend" : nameText
        return "Ready, \(name)!"
    }

    private var vizReadySubtitle: String {
        switch selectedRole {
        case .curious: return "Let's explore the world of AI together. I'll make it fun!"
        case .student: return "I'll help you ace AI topics for school. Let's learn!"
        case .professional: return "Let's build your AI skills for career growth!"
        case .fun: return "Time to have fun while learning something amazing!"
        }
    }

    // MARK: - Reusable Components
    private func experienceOption(_ level: UserProfile.ExperienceLevel, emoji: String, label: String, detail: String) -> some View {
        selectionRow(emoji: emoji, label: label, detail: detail, isSelected: selectedExperience == level) {
            selectedExperience = level
            HapticService.shared.lightTap()
        }
    }

    private func roleOption(_ role: UserProfile.UserRole, emoji: String, label: String, detail: String) -> some View {
        selectionRow(emoji: emoji, label: label, detail: detail, isSelected: selectedRole == role) {
            selectedRole = role
            HapticService.shared.lightTap()
        }
    }

    private func selectionRow(emoji: String, label: String, detail: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    if let detail {
                        Text(detail)
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.aiSuccess)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.aiSuccess.opacity(0.08) : Color.aiCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.aiSuccess : Color.aiTextSecondary.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Continue")
                .font(.aiHeadline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
        }
    }
}
