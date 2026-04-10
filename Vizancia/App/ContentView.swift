import SwiftUI

struct ContentView: View {
    @Bindable var user: UserProfile
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GamesHubView(user: user)
                .tabItem {
                    Label("Play", systemImage: "gamecontroller.fill")
                }
                .tag(0)

            LearnView(user: user)
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(1)

            TrainView(user: user)
                .tabItem {
                    Label("Train", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(2)

            CommunityView(user: user)
                .tabItem {
                    Label("Community", systemImage: "person.2.fill")
                }
                .tag(3)

            ProgressDashboardView(user: user)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
        .tint(Color.aiPrimary)
        .onAppear {
            user.checkHeartRefill()
            StreakService.shared.updateStreak(for: user)
        }
    }
}
