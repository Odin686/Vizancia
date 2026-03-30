import SwiftUI

struct VizMascotView: View {
    var size: CGFloat = 36

    @State private var isWaving = false
    @State private var waveAngle: Double = 0

    var body: some View {
        Image("viz_full")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
            .rotationEffect(.degrees(waveAngle), anchor: .bottom)
            .onAppear {
                scheduleWave()
            }
    }

    private func scheduleWave() {
        let delay = Double.random(in: 15...40)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            performWave()
        }
    }

    private func performWave() {
        // Quick 3-tilt wave then back to still
        let tilt: Double = 5
        let speed: Double = 0.12

        withAnimation(.easeInOut(duration: speed)) { waveAngle = tilt }
        after(speed) { withAnimation(.easeInOut(duration: speed)) { waveAngle = -tilt } }
        after(speed * 2) { withAnimation(.easeInOut(duration: speed)) { waveAngle = tilt } }
        after(speed * 3) { withAnimation(.easeInOut(duration: speed)) { waveAngle = -tilt } }
        after(speed * 4) { withAnimation(.easeInOut(duration: speed)) { waveAngle = tilt * 0.5 } }
        after(speed * 5) {
            withAnimation(.easeInOut(duration: speed * 1.5)) { waveAngle = 0 }
            scheduleWave()
        }
    }

    private func after(_ delay: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
}
