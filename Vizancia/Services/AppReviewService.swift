import StoreKit
import SwiftUI

/// Manages App Store review prompts — triggers at optimal positive moments.
class AppReviewService {
    static let shared = AppReviewService()

    private let reviewCountKey = "appReviewActionCount"
    private let lastReviewDateKey = "lastReviewRequestDate"

    /// Call this after positive moments (lesson complete, level up, streak milestone)
    func recordPositiveMoment() {
        let count = UserDefaults.standard.integer(forKey: reviewCountKey) + 1
        UserDefaults.standard.set(count, forKey: reviewCountKey)

        // Show review prompt at 5, 15, and 40 positive moments
        // (Apple limits actual display to 3x per 365 days)
        if [5, 15, 40].contains(count) {
            requestReviewIfEligible()
        }
    }

    /// Smart review request — respects 60-day cooldown
    private func requestReviewIfEligible() {
        let lastDate = UserDefaults.standard.object(forKey: lastReviewDateKey) as? Date ?? .distantPast
        let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 999

        guard daysSinceLastRequest >= 60 else { return }

        UserDefaults.standard.set(Date(), forKey: lastReviewDateKey)
        Self.requestReview()
    }

    /// Direct review request (from Settings "Rate Us" button)
    static func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
