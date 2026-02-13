import SwiftUI
import SwiftData

@main
struct AIAcademyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: UserProfile.self)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    
    var body: some View {
        Group {
            if let user = users.first {
                if user.onboardingCompleted {
                    ContentView(user: user)
                } else {
                    OnboardingView(user: user)
                }
            } else {
                Color.clear.onAppear { createUser() }
            }
        }
    }
    
    private func createUser() {
        let user = UserProfile()
        modelContext.insert(user)
        try? modelContext.save()
    }
}
