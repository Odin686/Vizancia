import SwiftUI

struct SpeedRoundGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining = 60
    @State private var score = 0
    @State private var currentQ: Question?
    @State private var selectedAnswer = ""
    @State private var isGameOver = false
    @State private var timer: Timer?
    @State private var allQuestions: [Question] = []
    @State private var shuffledOptions: [String] = []
    @State private var flashColor: Color = .clear
    @State private var showTutorial = true
    @State private var combo = 0
    @State private var maxCombo = 0
    @State private var multiplier = 1
    @State private var showComboText = false
    @State private var questionsAnswered = 0

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Speed Round",
                    icon: "bolt.fill",
                    color: .aiOrange,
                    rules: [
                        "Answer as many questions as you can in 60 seconds",
                        "Each correct answer earns points",
                        "Build combos for score multipliers!",
                        "3+ in a row = 2×, 6+ = 3×, 9+ = 4×"
                    ]
                ) { showTutorial = false; startGame() }
            } else if isGameOver {
                gameOverView
            } else {
                VStack(spacing: 16) {
                    // Timer & Score
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(timeRemaining <= 10 ? .aiError : .aiOrange)
                            Text("\(timeRemaining)s")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(timeRemaining <= 10 ? .aiError : .aiOrange)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            if multiplier > 1 {
                                Text("\(multiplier)×")
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundColor(.aiWarning)
                            }
                            Image(systemName: "star.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(score)")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(.aiTextPrimary)
                        }
                    }
                    .padding(.horizontal)

                    // Combo indicator
                    if combo > 0 {
                        HStack(spacing: 6) {
                            ForEach(0..<min(combo, 12), id: \.self) { i in
                                Circle()
                                    .fill(i < 3 ? Color.aiSuccess :
                                          i < 6 ? Color.aiOrange :
                                          i < 9 ? Color.aiWarning : Color.aiError)
                                    .frame(width: 8, height: 8)
                            }
                            if combo >= 3 {
                                Text("\(multiplier)×")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.aiWarning)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    if let q = currentQ {
                        Text(q.questionText)
                            .font(.aiTitle3())
                            .foregroundColor(.aiTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 10) {
                            ForEach(shuffledOptions, id: \.self) { option in
                                Button {
                                    checkAnswer(option, for: q)
                                } label: {
                                    Text(option)
                                        .font(.aiBody())
                                        .foregroundColor(.aiTextPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color.aiCard)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            
            // Flash overlay
            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)

            // Combo popup
            if showComboText && combo >= 3 {
                VStack(spacing: 4) {
                    Text("\(combo)× COMBO!")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.aiWarning)
                    Text("Score ×\(multiplier)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.aiWarning.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiWarning.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.aiWarning.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
                .allowsHitTesting(false)
            }
        }
        .onAppear { if !showTutorial { startGame() } }
        .onDisappear { timer?.invalidate() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)
            Text("Time's Up!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            // Stats
            HStack(spacing: 20) {
                gameOverStat(value: "\(questionsAnswered)", label: "Answered", icon: "questionmark.circle", color: .aiPrimary)
                gameOverStat(value: "\(maxCombo)×", label: "Max Combo", icon: "bolt.fill", color: .aiWarning)
                gameOverStat(value: "\(multiplier > 1 ? multiplier : maxCombo >= 3 ? 2 : 1)×", label: "Best Multi", icon: "star.fill", color: .aiOrange)
            }

            if score > (user.gameHighScores["speedRound"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }
            
            VStack(spacing: 12) {
                Button {
                    isGameOver = false
                    startGame()
                } label: {
                    Text("Play Again")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal, 30)
        }
    }

    private func gameOverStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
    }

    private func startGame() {
        allQuestions = LessonContentProvider.shared.allCategories
            .flatMap { $0.lessons }
            .flatMap { $0.questions }
            .filter { $0.type == .multipleChoice || $0.type == .trueFalse }
            .shuffled()
        score = 0
        combo = 0
        maxCombo = 0
        multiplier = 1
        questionsAnswered = 0
        timeRemaining = 60
        nextQuestion()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func nextQuestion() {
        if allQuestions.isEmpty {
            allQuestions = LessonContentProvider.shared.allCategories.flatMap { $0.lessons }.flatMap { $0.questions }.filter { $0.type == .multipleChoice || $0.type == .trueFalse }.shuffled()
        }
        currentQ = allQuestions.removeFirst()
        shuffledOptions = currentQ?.options.shuffled() ?? []
    }
    
    private func checkAnswer(_ answer: String, for question: Question) {
        questionsAnswered += 1
        if answer == question.correctAnswer {
            combo += 1
            maxCombo = max(maxCombo, combo)
            multiplier = min(4, 1 + combo / 3)
            let points = 10 * multiplier
            score += points
            flashColor = .aiSuccess
            HapticService.shared.success()
            SoundService.shared.play(.correct)

            if combo >= 3 && combo % 3 == 0 {
                withAnimation(.spring(response: 0.3)) { showComboText = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation { showComboText = false }
                }
            }
        } else {
            combo = 0
            multiplier = 1
            flashColor = .aiError
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { flashColor = .clear }
        nextQuestion()
    }
    
    private func endGame() {
        timer?.invalidate()
        let xp = score / 2
        user.addXP(xp)
        user.todayXP += xp
        if score > (user.gameHighScores["speedRound"] ?? 0) {
            user.gameHighScores["speedRound"] = score
        }
        user.gamesPlayed += 1
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}
