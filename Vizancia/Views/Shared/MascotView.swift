import SwiftUI

// MARK: - Mascot Mood
enum MascotMood: String, CaseIterable {
    case waving       // Default — friendly greeting
    case celebrating  // Perfect score, level up, achievement
    case thinking     // During questions, loading
    case sad          // Wrong answer, lost hearts

    var imageName: String {
        switch self {
        case .waving: return "mascot_waving"
        case .celebrating: return "mascot_celebrating"
        case .thinking: return "mascot_thinking"
        case .sad: return "mascot_sad"
        }
    }
}

// MARK: - Mascot View (Compact Corner Mascot)
struct MascotView: View {
    let mood: MascotMood
    var message: String? = nil
    var size: CGFloat = 80
    var showBubble: Bool = true

    @State private var isAnimating = false
    @State private var showMessage = false
    @State private var bouncing = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Speech bubble
            if showBubble, let message, showMessage {
                speechBubble(message)
                    .transition(.scale(scale: 0.5, anchor: .bottomTrailing).combined(with: .opacity))
            }

            // Mascot image with animations
            Image(mood.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating ? waveAngle : 0), anchor: .bottom)
                .scaleEffect(bouncing ? 1.05 : 1.0)
                .offset(y: bouncing ? -4 : 0)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .onTapGesture {
                    triggerTapAnimation()
                }
        }
        .onAppear {
            startIdleAnimation()
            if message != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showMessage = true
                    }
                }
            }
        }
    }

    private var waveAngle: Double {
        switch mood {
        case .waving: return 6
        case .celebrating: return 4
        case .thinking: return -3
        case .sad: return -2
        }
    }

    // MARK: - Speech Bubble
    private func speechBubble(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.aiTextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            )
            .overlay(alignment: .bottomTrailing) {
                // Little triangle pointing to mascot
                Triangle()
                    .fill(Color.aiCard)
                    .frame(width: 10, height: 8)
                    .offset(x: -12, y: 6)
            }
            .frame(maxWidth: 180)
    }

    // MARK: - Animations

    private func startIdleAnimation() {
        // Gentle rocking/wave animation
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
            .delay(0.3)
        ) {
            isAnimating = true
        }

        // Occasional bounce
        scheduleBounce()
    }

    private func scheduleBounce() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 3...6)) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                bouncing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bouncing = false
                }
                scheduleBounce()
            }
        }
    }

    private func triggerTapAnimation() {
        HapticService.shared.lightTap()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.3)) {
            bouncing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bouncing = false
            }
        }
    }
}

// MARK: - Triangle Shape (for speech bubble pointer)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mascot Overlay Modifier
/// Use as: .mascotOverlay(mood: .waving, message: "Hello!")
struct MascotOverlayModifier: ViewModifier {
    let mood: MascotMood
    var message: String? = nil
    var alignment: Alignment = .bottomTrailing
    var size: CGFloat = 70
    var show: Bool = true

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if show && appeared {
                    MascotView(mood: mood, message: message, size: size)
                        .padding(16)
                        .transition(.scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    func mascotOverlay(
        mood: MascotMood,
        message: String? = nil,
        alignment: Alignment = .bottomTrailing,
        size: CGFloat = 70,
        show: Bool = true
    ) -> some View {
        modifier(MascotOverlayModifier(
            mood: mood,
            message: message,
            alignment: alignment,
            size: size,
            show: show
        ))
    }
}

// MARK: - Contextual Mascot Messages
struct MascotMessages {
    static func playGreeting(for user: UserProfile) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning! Ready to play? 🎮" }
        if hour < 17 { return "Let's have some fun! 🚀" }
        return "Evening practice! 🌙"
    }

    static func trainEncouragement(for user: UserProfile) -> String {
        if user.missedQuestionIds.count > 5 {
            return "Let's review those tricky questions! 💪"
        }
        if !user.hasCompletedDailyChallenge {
            return "Don't forget your daily challenge! ⭐"
        }
        return "Keep training — you're getting stronger! 🧠"
    }

    static func lessonComplete(isPerfect: Bool) -> String {
        if isPerfect { return "PERFECT! You're amazing! 🌟" }
        return "Great job! Keep it up! 🎉"
    }

    static func wrongAnswer() -> String {
        let messages = [
            "Don't worry, you'll get it! 💪",
            "Learning from mistakes! 🧠",
            "Almost! Try again! 🔄",
            "That's a tough one! 🤔"
        ]
        return messages.randomElement()!
    }

    static func correctAnswer() -> String {
        let messages = [
            "Nailed it! ⚡",
            "You're on fire! 🔥",
            "Brilliant! 🌟",
            "That's right! 💎"
        ]
        return messages.randomElement()!
    }

    static func streak(_ days: Int) -> String {
        if days >= 7 { return "\(days)-day streak! Unstoppable! 🔥" }
        if days >= 3 { return "\(days) days in a row! Keep going! 💪" }
        return "Nice streak! \(days) days! ⭐"
    }
}
