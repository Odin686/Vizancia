import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let x: CGFloat
    let rotation: Double
    let delay: Double
    let speed: Double
}

struct ConfettiView: View {
    let isActive: Bool

    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    private let colors: [Color] = [.aiPrimary, .aiOrange, .aiSuccess, .aiWarning, .aiError, .aiSecondary]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .rotationEffect(.degrees(animate ? piece.rotation + 360 : piece.rotation))
                        .offset(
                            x: piece.x - geo.size.width / 2,
                            y: animate ? geo.size.height + 50 : -50
                        )
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.speed)
                            .delay(piece.delay),
                            value: animate
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, active in
            if active {
                generatePieces()
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animate = true
                }
            }
        }
    }

    private func generatePieces() {
        pieces = (0..<40).map { _ in
            ConfettiPiece(
                color: colors.randomElement() ?? .aiPrimary,
                size: CGFloat.random(in: 6...12),
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                rotation: Double.random(in: 0...360),
                delay: Double.random(in: 0...0.5),
                speed: Double.random(in: 1.5...3.0)
            )
        }
    }
}

struct LevelUpBannerView: View {
    let levelTitle: String
    let level: Int
    @State private var show = false

    var body: some View {
        if show {
            VStack(spacing: 8) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.aiWarning)
                Text("Level Up!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Level \(level) - \(levelTitle)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.aiPrimaryGradient)
                    .shadow(color: .aiPrimary.opacity(0.4), radius: 16, y: 8)
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}
