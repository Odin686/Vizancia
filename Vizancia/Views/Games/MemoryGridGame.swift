import SwiftUI

struct MemoryCard: Identifiable {
    let id = UUID()
    let symbol: String
    let label: String
    var isFaceUp = false
    var isMatched = false
}

struct MemoryGridGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [MemoryCard] = []
    @State private var firstFlippedIndex: Int?
    @State private var moves = 0
    @State private var pairsFound = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var isProcessing = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?

    private let pairs: [(String, String)] = [
        ("brain.head.profile", "AI"),
        ("cpu", "Chip"),
        ("text.bubble", "Chat"),
        ("eye", "Vision"),
        ("waveform", "Audio"),
        ("lock.shield", "Safety"),
        ("sparkles", "GenAI"),
        ("globe", "Web")
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Memory Grid",
                    icon: "square.grid.3x3.topleft.filled",
                    color: .aiSecondary,
                    rules: [
                        "Flip two cards at a time to find matching pairs",
                    "Match all 8 pairs to complete the game",
                        "Fewer moves and faster time = higher score",
                        "Matched pairs stay face-up in green"
                    ]
                ) { showTutorial = false; startGame() }
            } else if isGameOver {
                gameOverView
            } else {
                VStack(spacing: 16) {
                    // Header: close, timer, moves
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.aiSecondary)
                            Text("\(elapsedSeconds)s")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(.aiSecondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(moves)")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(.aiTextPrimary)
                        }
                    }
                    .padding(.horizontal)

                    // Pairs found
                    Text("Pairs: \(pairsFound)/8")
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextSecondary)

                    // Card grid
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                            cardView(card: card, index: index)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
        }
        .onAppear { if !showTutorial { startGame() } }
        .onDisappear { timer?.invalidate() }
    }

    private func cardView(card: MemoryCard, index: Int) -> some View {
        Button {
            flipCard(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isMatched ? Color.aiSuccess.opacity(0.2) : (card.isFaceUp ? Color.aiCard : Color.aiSecondary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.isMatched ? Color.aiSuccess : Color.aiSecondary.opacity(0.3), lineWidth: 2)
                    )

                if card.isFaceUp || card.isMatched {
                    VStack(spacing: 4) {
                        Image(systemName: card.symbol)
                            .font(.system(size: 24))
                            .foregroundColor(card.isMatched ? .aiSuccess : .aiSecondary)
                        Text(card.label)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(card.isMatched ? .aiSuccess : .aiTextPrimary)
                    }
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(height: 90)
            .scaleEffect(x: card.isFaceUp || card.isMatched ? 1 : 1, y: 1)
            .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
            .animation(.easeInOut(duration: 0.3), value: card.isMatched)
        }
        .disabled(card.isFaceUp || card.isMatched || isProcessing)
    }

    private var gameOverView: some View {
        let score = calculateScore()

        return VStack(spacing: 24) {
            Image(systemName: "square.grid.3x3.topleft.filled")
                .font(.system(size: 50))
                .foregroundColor(.aiSecondary)
            Text("Game Complete!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.aiSecondary)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.aiWarning)
                    Text("\(moves)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text("Moves")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                }
                VStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.aiSecondary)
                    Text("\(elapsedSeconds)s")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text("Time")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                }
                VStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.aiPrimary)
                    Text("\(score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text("Score")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                }
            }

            if score > (user.gameHighScores["memoryGrid"] ?? 0) {
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

    private func calculateScore() -> Int {
        // Base 100, minus 2 per move over 8 (perfect), minus 1 per second over 15
        let movesPenalty = max(0, (moves - 8) * 2)
        let timePenalty = max(0, (elapsedSeconds - 15))
        return max(10, 100 - movesPenalty - timePenalty)
    }

    private func startGame() {
        var deck: [MemoryCard] = []
        for pair in pairs {
            deck.append(MemoryCard(symbol: pair.0, label: pair.1))
            deck.append(MemoryCard(symbol: pair.0, label: pair.1))
        }
        cards = deck.shuffled()
        moves = 0
        pairsFound = 0
        elapsedSeconds = 0
        firstFlippedIndex = nil
        isProcessing = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func flipCard(at index: Int) {
        guard !isProcessing else { return }
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            cards[index].isFaceUp = true
        }
        HapticService.shared.lightTap()

        if let first = firstFlippedIndex {
            moves += 1
            isProcessing = true

            if cards[first].symbol == cards[index].symbol {
                // Match found
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        cards[first].isMatched = true
                        cards[index].isMatched = true
                    }
                    pairsFound += 1
                    HapticService.shared.success()
                    firstFlippedIndex = nil
                    isProcessing = false

                    if pairsFound == 8 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            endGame()
                        }
                    }
                }
            } else {
                // No match — flip back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        cards[first].isFaceUp = false
                        cards[index].isFaceUp = false
                    }
                    HapticService.shared.error()
                    firstFlippedIndex = nil
                    isProcessing = false
                }
            }
        } else {
            firstFlippedIndex = index
        }
    }

    private func endGame() {
        timer?.invalidate()
        let score = calculateScore()
        let xp = score / 2
        user.addXP(xp)
        user.todayXP += xp
        if score > (user.gameHighScores["memoryGrid"] ?? 0) {
            user.gameHighScores["memoryGrid"] = score
        }
        user.gamesPlayed += 1
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}
