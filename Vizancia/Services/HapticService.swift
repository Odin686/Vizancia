import UIKit

class HapticService {
    static let shared = HapticService()
    var isEnabled = true

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func lightTap() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }

    func mediumTap() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }

    func heavyTap() {
        guard isEnabled else { return }
        heavyGenerator.impactOccurred()
    }

    func success() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    func warning() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    // Double-pulse for combo streaks
    func comboPulse() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred(intensity: 0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            heavyGenerator.impactOccurred(intensity: 1.0)
        }
    }

    // Rising triple-tap for level up
    func levelUp() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [self] in
            mediumGenerator.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { [self] in
            heavyGenerator.impactOccurred(intensity: 1.0)
        }
    }

    // Gentle nudge for card flip
    func cardFlip() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.5)
    }

    // Celebratory burst for perfect score
    func perfectScore() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            heavyGenerator.impactOccurred(intensity: 0.8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            mediumGenerator.impactOccurred(intensity: 0.6)
        }
    }
}
