import SwiftUI

struct VizMascotView: View {
    var size: CGFloat = 80
    var showMessage: Bool = true
    var message: String = ""
    var enableEyePop: Bool = true

    @State private var eyePopped = false
    @State private var eyeOffset: CGFloat = 0
    @State private var eyeScale: CGFloat = 0
    @State private var eyeRotation: Double = 0
    @State private var pushingBack = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Viz body
                Image("viz_happy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)

                // Animated eye overlay
                if eyePopped {
                    Image("viz_eye")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.35)
                        .offset(x: size * 0.25, y: eyeOffset)
                        .scaleEffect(eyeScale)
                        .rotationEffect(.degrees(eyeRotation))
                }
            }

            if showMessage && !message.isEmpty {
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            if enableEyePop {
                scheduleRandomEyePop()
            }
        }
    }

    private func scheduleRandomEyePop() {
        let delay = Double.random(in: 30...90)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            performEyePop()
        }
    }

    private func performEyePop() {
        // Pop out
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            eyePopped = true
            eyeScale = 1.0
            eyeOffset = size * 0.15
        }

        // Slinky wobble
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 3).delay(0.2)) {
            eyeOffset = size * 0.25
            eyeRotation = 8
        }

        // Wobble back
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 4).delay(0.5)) {
            eyeRotation = -5
        }

        // Settle
        withAnimation(.interpolatingSpring(stiffness: 120, damping: 5).delay(0.7)) {
            eyeRotation = 3
        }

        // Push back in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                eyeOffset = 0
                eyeScale = 0
                eyeRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                eyePopped = false
                scheduleRandomEyePop()
            }
        }

        HapticService.shared.lightTap()
    }
}

// MARK: - Simple Viz image (no animation, for small uses)
struct VizIcon: View {
    var size: CGFloat = 40

    var body: some View {
        Image("viz_happy")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}
