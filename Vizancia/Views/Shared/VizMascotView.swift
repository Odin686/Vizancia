import SwiftUI

struct VizMascotView: View {
    var size: CGFloat = 60

    @State private var bobOffset: CGFloat = 0
    @State private var isWaving = false
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        Image("viz_full")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
            .offset(y: bobOffset)
            .rotationEffect(.degrees(isWaving ? 3 : 0), anchor: .bottom)
            .shadow(color: .aiPrimary.opacity(glowOpacity), radius: 8, y: 4)
            .onAppear {
                startIdleAnimation()
                startGlowPulse()
                scheduleWave()
            }
    }

    private func startIdleAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            bobOffset = -4
        }
    }

    private func startGlowPulse() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.6
        }
    }

    private func scheduleWave() {
        let delay = Double.random(in: 20...50)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            performWave()
        }
    }

    private func performWave() {
        withAnimation(.easeInOut(duration: 0.15)) { isWaving = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) { isWaving = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.15)) { isWaving = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.15)) { isWaving = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.15)) { isWaving = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.2)) { isWaving = false }
            scheduleWave()
        }
    }
}
