import SwiftUI

struct PracticeMistakesView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var selectedAnswer = ""
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @State private var showingResult = false
    @State private var xpEarned = 0
    @State private var isComplete = false

    private var questions: [Question] {
        LessonContentProvider.shared.missedQuestions(for: user.missedQuestionIds)
    }

    private var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                if questions.isEmpty || isComplete {
                    completionView
                } else if let question = currentQuestion {
                    VStack(spacing: 0) {
                        topBar
                        progressBar

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                questionContent(question)
                                    .padding(.top, 20)

                                if showingResult {
                                    resultFeedback(question)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }

                        bottomAction
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundColor(.aiOrange)
                Text("Practice")
                    .font(.aiCaption())
                    .foregroundColor(.aiOrange)
            }
            Spacer()
            Text("\(currentIndex + 1)/\(questions.count)")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aiOrange.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aiOrange)
                    .frame(width: geo.size.width * (Double(currentIndex) / Double(max(questions.count, 1))))
                    .animation(.spring(response: 0.4), value: currentIndex)
            }
        }
        .frame(height: 8)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func questionContent(_ question: Question) -> some View {
        switch question.type {
        case .multipleChoice:
            MultipleChoiceView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .trueFalse:
            TrueFalseView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .matchPairs:
            MatchPairsView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .fillInBlank:
            FillInBlankView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .sortOrder:
            SortOrderView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .scenarioJudgment:
            ScenarioJudgmentView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        }
    }

    private func resultFeedback(_ question: Question) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                    .font(.title2)
                Text(isCorrect ? "Got it!" : "Keep practicing")
                    .font(.aiHeadline())
                    .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                Spacer()
            }
            Text(question.explanation)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill((isCorrect ? Color.aiSuccess : Color.aiError).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke((isCorrect ? Color.aiSuccess : Color.aiError).opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var bottomAction: some View {
        VStack {
            Divider()
            Button {
                if showingResult {
                    moveToNext()
                } else {
                    checkAnswer()
                }
            } label: {
                Text(showingResult ? (currentIndex < questions.count - 1 ? "Continue" : "Finish") : "Check")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedAnswer.isEmpty && !showingResult ? AnyShapeStyle(Color.aiOrange.opacity(0.4)) : AnyShapeStyle(Color.aiOrange))
                    )
            }
            .disabled(selectedAnswer.isEmpty && !showingResult)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.aiBackground)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: questions.isEmpty ? "checkmark.circle.fill" : "star.fill")
                .font(.system(size: 60))
                .foregroundColor(questions.isEmpty ? .aiSuccess : .aiOrange)

            Text(questions.isEmpty ? "All Caught Up!" : "Practice Complete!")
                .font(.aiLargeTitle)
                .foregroundColor(.aiTextPrimary)

            if questions.isEmpty {
                Text("You've mastered all your missed questions.")
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("You got \(correctCount) out of \(currentIndex) correct.\nKeep it up!")
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if xpEarned > 0 {
                Text("+\(xpEarned) XP")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.aiOrange)
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }

    private func checkAnswer() {
        guard let question = currentQuestion, !selectedAnswer.isEmpty else { return }

        let correct: Bool
        if question.type == .sortOrder {
            correct = selectedAnswer == question.correctAnswers.joined(separator: "||")
        } else if question.type == .matchPairs {
            correct = selectedAnswer == "matched"
        } else {
            correct = selectedAnswer == question.correctAnswer
        }

        isCorrect = correct
        hasAnswered = true
        showingResult = true

        if correct {
            correctCount += 1
            let xp = 5
            xpEarned += xp
            user.addXP(xp)
            user.todayXP += xp
            user.removeMissedQuestion(question.id)
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }
    }

    private func moveToNext() {
        if currentIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                selectedAnswer = ""
                hasAnswered = false
                showingResult = false
                isCorrect = false
            }
        } else {
            isComplete = true
        }
    }
}
