import SwiftUI

struct FactOrFictionGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var currentIndex = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var showResult = false
    @State private var lastCorrect = false
    @State private var flashColor: Color = .clear
    @State private var shuffledClaims: [(claim: String, isFact: Bool, explanation: String)] = []

    private let totalQuestions = 15

    private let claims: [(claim: String, isFact: Bool, explanation: String)] = [
        ("GPT-4 can process images as input", true, "GPT-4 is multimodal and can analyze images."),
        ("AI can smell food through your phone", false, "AI cannot process physical smells — it only works with digital data."),
        ("Netflix uses AI to recommend shows", true, "Netflix's recommendation engine uses ML to personalize content."),
        ("AI models dream when they sleep", false, "AI doesn't sleep or dream — it only runs when processing."),
        ("Spotify uses AI to create Discover Weekly playlists", true, "Spotify's recommendation system uses collaborative filtering and NLP."),
        ("ChatGPT was trained on the entire internet", false, "It was trained on a large but curated subset of internet text, not everything."),
        ("AI can detect some cancers better than doctors", true, "Studies show AI matching or exceeding radiologists for certain cancers."),
        ("Self-driving cars use a single AI model", false, "They use multiple AI systems working together — vision, planning, control."),
        ("The word 'robot' is over 100 years old", true, "It was coined in 1920 in Karel Čapek's play R.U.R."),
        ("AI can generate human DNA sequences", false, "While AI can analyze DNA, it cannot create functional human genetic code."),
        ("Google's AI once beat the world champion at Go", true, "AlphaGo defeated Lee Sedol in 2016."),
        ("All AI is based on neural networks", false, "Many AI techniques exist including decision trees, SVMs, and rule-based systems."),
        ("DALL-E is named after Salvador Dalí and WALL-E", true, "The name combines the surrealist artist with Pixar's robot character."),
        ("AI can write music that sounds like a specific artist", true, "AI voice cloning and style transfer can mimic specific musical styles."),
        ("Training GPT-3 used more energy than a car uses in its lifetime", false, "Training used significant energy but not more than a car's lifetime fuel consumption."),
        // New claims
        ("GitHub Copilot uses AI to suggest code", true, "Copilot is powered by OpenAI's models to autocomplete code in real time."),
        ("AI can perfectly translate any language", false, "AI translation is impressive but still makes errors, especially with idioms and rare languages."),
        ("Tesla's Autopilot is fully self-driving", false, "Despite the name, Autopilot is a driver-assistance system that still requires human supervision."),
        ("AI can compose an entire symphony", true, "AI tools like AIVA and MuseNet can compose long-form classical music."),
        ("Siri was one of the first mainstream voice assistants", true, "Apple launched Siri in 2011, bringing voice assistants to millions of iPhones."),
        ("AI can read your emotions through your screen", false, "While emotion recognition AI exists for cameras, it can't read emotions through a screen."),
        ("DeepMind's AlphaFold solved a 50-year-old biology problem", true, "AlphaFold predicted the 3D structure of proteins, a grand challenge in biology."),
        ("AI models get smarter every time you use them", false, "Trained models are static — they don't learn from individual user interactions without retraining."),
        ("The first AI program was written in the 1950s", true, "The Logic Theorist, created in 1956, is considered the first AI program."),
        ("AI can create fake videos of real people", true, "Deepfake technology can generate convincing but fake videos of real individuals."),
        ("All AI models require the internet to work", false, "Many AI models can run completely offline on local devices."),
        ("GPT stands for 'General Purpose Technology'", false, "GPT stands for 'Generative Pre-trained Transformer.'"),
        ("AI is used to detect fraud in banking", true, "Banks use ML algorithms to flag suspicious transactions in real time."),
        ("AI can accurately predict earthquakes", false, "Despite research, AI cannot reliably predict when earthquakes will occur."),
        ("The Turing Test was proposed before computers existed", false, "Alan Turing proposed it in 1950, after early computers were already built."),
        ("AI powers the filters on Instagram and Snapchat", true, "Face detection and AR filters use neural networks to track and modify faces."),
        ("Larger AI models are always more accurate", false, "Bigger isn't always better — smaller, specialized models can outperform larger general ones."),
        ("AI can help discover new medicines", true, "AI is used in drug discovery to predict molecular interactions and speed up research."),
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Fact or Fiction",
                    icon: "hand.thumbsup.fill",
                    color: .aiSuccess,
                    rules: [
                        "You'll see a claim about AI",
                        "Decide if it's a fact or fiction",
                        "See the explanation after each answer",
                        "15 claims — how well do you know AI?"
                    ]
                ) { showTutorial = false }
            } else if isGameOver {
                gameOverView
            } else if currentIndex < min(totalQuestions, shuffledClaims.count) {
                let item = shuffledClaims[currentIndex]
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        Text("\(currentIndex + 1)/\(totalQuestions)")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(score)")
                                .font(.aiRounded(.body, weight: .bold))
                                .foregroundColor(.aiPrimary)
                        }
                    }
                    .padding(.horizontal)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiTextSecondary.opacity(0.15))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiSuccess)
                                .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(totalQuestions), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal)

                    Spacer()

                    // Claim card
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.aiPrimary)

                        Text(item.claim)
                            .font(.aiTitle3())
                            .foregroundColor(.aiTextPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)

                    if showResult {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Correct!" : "Wrong!")
                            }
                            .font(.aiHeadline())
                            .foregroundColor(lastCorrect ? .aiSuccess : .aiError)

                            Text(item.isFact ? "This is a FACT" : "This is FICTION")
                                .font(.aiRounded(.body, weight: .bold))
                                .foregroundColor(.aiPrimary)

                            Text(item.explanation)
                                .font(.aiCaption())
                                .foregroundColor(.aiTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .transition(.opacity)

                        // Next button
                        Button {
                            showResult = false
                            currentIndex += 1
                            if currentIndex >= totalQuestions {
                                endGame()
                            }
                        } label: {
                            Text(currentIndex + 1 >= totalQuestions ? "See Results" : "Next")
                                .font(.aiHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                        }
                        .padding(.horizontal)
                    } else {
                        // Fact / Fiction buttons
                        HStack(spacing: 16) {
                            Button { answerTapped(isFact: true) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("Fact")
                                        .font(.aiHeadline())
                                }
                                .foregroundColor(.aiSuccess)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiSuccess.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.aiSuccess.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }

                            Button { answerTapped(isFact: false) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                    Text("Fiction")
                                        .font(.aiHeadline())
                                }
                                .foregroundColor(.aiError)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiError.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.aiError.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.vertical)
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onAppear { shuffledClaims = claims.shuffled() }
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiSuccess)
            Text("Game Over!")
                .font(.aiLargeTitle)
            Text("\(score)/\(totalQuestions)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            if score > (user.gameHighScores["factOrFiction"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }

            VStack(spacing: 12) {
                Button {
                    currentIndex = 0
                    score = 0
                    isGameOver = false
                    shuffledClaims = claims.shuffled()
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

    private func answerTapped(isFact: Bool) {
        let item = shuffledClaims[currentIndex]
        lastCorrect = item.isFact == isFact
        if lastCorrect {
            score += 1
            flashColor = .aiSuccess
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            flashColor = .aiError
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }

        withAnimation { showResult = true }
    }

    private func endGame() {
        let xp = score * 6
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["factOrFiction"] ?? 0) {
            user.gameHighScores["factOrFiction"] = score
        }
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}
