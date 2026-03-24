import SwiftUI

struct GameTutorialView: View {
    let title: String
    let icon: String
    let color: Color
    let rules: [String]
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.aiLargeTitle)
                .foregroundColor(.aiTextPrimary)

            Text("How to Play")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
                .textCase(.uppercase)
                .tracking(1.5)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(color)
                        }
                        Text(rule)
                            .font(.aiBody())
                            .foregroundColor(.aiTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onStart()
                } label: {
                    Text("Let's Go!")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(color)
                        )
                }

                Button { dismiss() } label: {
                    Text("Back")
                        .font(.aiBody())
                        .foregroundColor(.aiTextSecondary)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}
