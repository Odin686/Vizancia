import SwiftUI

/// Reusable empty state view with icon, title, description, and optional action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var iconBounce = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.06))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.aiPrimary.opacity(0.5))
                    .offset(y: iconBounce ? -4 : 4)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: iconBounce)
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextPrimary)

            Text(description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.aiPrimary.opacity(0.1))
                        )
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .onAppear { iconBounce = true }
    }
}
