import SwiftUI

struct HeartEarnGameView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var round = 0
    @State private var isComplete = false
    @State private var currentTerm: JargonTerm?
    @State private var shuffledOptions: [String] = []
    @State private var flashColor: Color = .clear
    @State private var terms: [JargonTerm] = []

    private let totalRounds = 5
    private let requiredScore = 3

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                gameView
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onAppear { startGame() }
    }

    private var gameView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.aiError)
                    Text("Earn a Heart")
                        .font(.aiCaption())
                        .foregroundColor(.aiError)
                }
                Spacer()
                Text("\(score)/\(requiredScore)")
                    .font(.aiRounded(.body, weight: .bold))
                    .foregroundColor(score >= requiredScore ? .aiSuccess : .aiPrimary)
            }
            .padding(.horizontal)

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<totalRounds, id: \.self) { i in
                    Circle()
                        .fill(i < round ? (i < score ? Color.aiSuccess : Color.aiError) : Color.aiTextSecondary.opacity(0.2))
                        .frame(width: 10, height: 10)
                }
            }

            Spacer()

            if let term = currentTerm {
                VStack(spacing: 8) {
                    Text("What is")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                    Text(term.term)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                    Text("?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                }

                VStack(spacing: 10) {
                    ForEach(shuffledOptions, id: \.self) { option in
                        Button {
                            checkAnswer(option, for: term)
                        } label: {
                            Text(option)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.vertical)
    }

    private var completionView: some View {
        let earned = score >= requiredScore
        return VStack(spacing: 24) {
            Spacer()

            Image(systemName: earned ? "heart.fill" : "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(earned ? .aiError : .aiTextSecondary)

            Text(earned ? "Heart Earned!" : "Not Quite")
                .font(.aiLargeTitle)
                .foregroundColor(.aiTextPrimary)

            Text(earned ? "You got \(score)/\(totalRounds) — here's your heart!" : "You needed \(requiredScore) correct. Try again anytime!")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }

    private func startGame() {
        terms = JargonTerm.all.shuffled()
        score = 0
        round = 0
        nextTerm()
    }

    private func nextTerm() {
        if terms.isEmpty { terms = JargonTerm.all.shuffled() }
        let term = terms.removeFirst()
        currentTerm = term
        var options = [term.definition]
        let others = JargonTerm.all.filter { $0.term != term.term }.map { $0.definition }.shuffled().prefix(3)
        options.append(contentsOf: others)
        shuffledOptions = options.shuffled()
    }

    private func checkAnswer(_ answer: String, for term: JargonTerm) {
        round += 1
        if answer == term.definition {
            score += 1
            flashColor = .aiSuccess
            HapticService.shared.success()
        } else {
            flashColor = .aiError
            HapticService.shared.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { flashColor = .clear }

        if round >= totalRounds {
            if score >= requiredScore {
                user.earnHeart()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isComplete = true
            }
        } else {
            nextTerm()
        }
    }
}
