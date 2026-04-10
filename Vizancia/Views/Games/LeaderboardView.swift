import SwiftUI
import GameKit

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameKit = GameKitService.shared
    @State private var selectedTab = 0
    @State private var topPlayers: [LeaderboardPlayer] = []
    @State private var localPlayer: LeaderboardPlayer?
    @State private var isLoading = true

    private let tabs = [
        ("All-Time XP", GameKitService.totalXPLeaderboard, "star.fill", Color.aiPrimary),
        ("This Week", GameKitService.weeklyXPLeaderboard, "flame.fill", Color.aiOrange),
        ("Duel Wins", GameKitService.duelWinsLeaderboard, "trophy.fill", Color.aiWarning),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector

                if !gameKit.isAuthenticated {
                    notSignedInView
                } else if isLoading {
                    loadingView
                } else if topPlayers.isEmpty {
                    emptyView
                } else {
                    // Leaderboard List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            // Podium (top 3)
                            if topPlayers.count >= 3 {
                                podiumView
                            }

                            // Remaining Players
                            ForEach(topPlayers.dropFirst(min(3, topPlayers.count))) { player in
                                leaderboardRow(player: player)
                            }

                            // Local Player (if not in top 10)
                            if let local = localPlayer,
                               !topPlayers.contains(where: { $0.isLocalPlayer }) {
                                Divider().padding(.vertical, 4)
                                HStack {
                                    Text("Your Rank")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.aiTextSecondary)
                                    Spacer()
                                }
                                leaderboardRow(player: local)
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            gameKit.showLeaderboard(tabs[selectedTab].1)
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.aiTextSecondary)
                        }
                        .disabled(!gameKit.isAuthenticated)

                        Button("Done") { dismiss() }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
            .onChange(of: selectedTab) { _, _ in
                Task { await loadScores() }
            }
            .task { await loadScores() }
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedTab = i }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tabs[i].2)
                                .font(.system(size: 12))
                            Text(tabs[i].0)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(selectedTab == i ? tabs[i].3 : Color.aiCard)
                        )
                        .foregroundColor(selectedTab == i ? .white : .aiTextSecondary)
                        .overlay(
                            Capsule()
                                .stroke(selectedTab == i ? Color.clear : Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Podium (Top 3)
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if topPlayers.count > 1 {
                podiumPlayer(topPlayers[1], place: 2, height: 80)
            }
            if topPlayers.count > 0 {
                podiumPlayer(topPlayers[0], place: 1, height: 100)
            }
            if topPlayers.count > 2 {
                podiumPlayer(topPlayers[2], place: 3, height: 65)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private func podiumPlayer(_ player: LeaderboardPlayer, place: Int, height: CGFloat) -> some View {
        VStack(spacing: 6) {
            // Crown for first place
            if place == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.aiWarning)
            }

            // Avatar circle
            ZStack {
                Circle()
                    .fill(podiumColor(place).opacity(0.15))
                    .frame(width: place == 1 ? 56 : 44, height: place == 1 ? 56 : 44)
                Circle()
                    .stroke(podiumColor(place), lineWidth: 2)
                    .frame(width: place == 1 ? 56 : 44, height: place == 1 ? 56 : 44)
                Text(String(player.displayName.prefix(1)).uppercased())
                    .font(.system(size: place == 1 ? 22 : 18, weight: .bold, design: .rounded))
                    .foregroundColor(podiumColor(place))
            }

            Text(player.displayName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(player.isLocalPlayer ? tabs[selectedTab].3 : .aiTextPrimary)
                .lineLimit(1)
                .frame(maxWidth: 80)

            Text(formatScore(player.score))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(tabs[selectedTab].3)

            // Podium block
            RoundedRectangle(cornerRadius: 8)
                .fill(podiumColor(place).opacity(0.15))
                .frame(height: height)
                .overlay(
                    Text("#\(place)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(podiumColor(place))
                )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Leaderboard Row
    private func leaderboardRow(player: LeaderboardPlayer) -> some View {
        HStack(spacing: 12) {
            Text("#\(player.rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .frame(width: 35, alignment: .leading)

            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Text(String(player.displayName.prefix(1)).uppercased())
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
            }

            Text(player.displayName)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(player.isLocalPlayer ? tabs[selectedTab].3 : .aiTextPrimary)

            Spacer()

            Text(formatScore(player.score))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(tabs[selectedTab].3)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(player.isLocalPlayer ? tabs[selectedTab].3.opacity(0.08) : Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(player.isLocalPlayer ? tabs[selectedTab].3.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - States
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading scores...")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "trophy")
                .font(.system(size: 44))
                .foregroundColor(.aiTextSecondary.opacity(0.3))
            Text("No scores yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
            Text("Complete lessons and play games to climb the leaderboard!")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notSignedInView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 44))
                .foregroundColor(.aiTextSecondary.opacity(0.3))
            Text("Game Center Required")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
            Text("Sign in to Game Center in Settings to see leaderboards and compete with others.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers
    private func loadScores() async {
        isLoading = true
        let leaderboardID = tabs[selectedTab].1
        topPlayers = await gameKit.loadTopScores(for: leaderboardID)
        localPlayer = await gameKit.loadLocalPlayerEntry(for: leaderboardID)
        isLoading = false
    }

    private func podiumColor(_ place: Int) -> Color {
        switch place {
        case 1: return .aiWarning
        case 2: return Color(red: 0.6, green: 0.65, blue: 0.7)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .aiTextSecondary
        }
    }

    private func formatScore(_ score: Int) -> String {
        if score >= 10000 {
            return String(format: "%.1fk", Double(score) / 1000.0)
        }
        return "\(score)"
    }
}
