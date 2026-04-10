import WidgetKit
import SwiftUI

// MARK: - Shared Data (read from App Group)
struct VizanciaWidgetData: Codable {
    var totalXP: Int
    var currentStreak: Int
    var currentLevel: Int
    var levelTitle: String
    var todayXP: Int
    var dailyXPGoal: Int
    var dailyGoalMet: Bool
    var hasCompletedDailyChallenge: Bool
    var dueReviewCount: Int
    var duelWins: Int

    static let placeholder = VizanciaWidgetData(
        totalXP: 1250,
        currentStreak: 7,
        currentLevel: 5,
        levelTitle: "AI Explorer",
        todayXP: 45,
        dailyXPGoal: 60,
        dailyGoalMet: false,
        hasCompletedDailyChallenge: false,
        dueReviewCount: 3,
        duelWins: 2
    )

    static func load() -> VizanciaWidgetData {
        guard let defaults = UserDefaults(suiteName: "group.ca.vizancia.shared"),
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(VizanciaWidgetData.self, from: data)
        else {
            return .placeholder
        }
        return decoded
    }

    func save() {
        guard let defaults = UserDefaults(suiteName: "group.ca.vizancia.shared"),
              let data = try? JSONEncoder().encode(self)
        else { return }
        defaults.set(data, forKey: "widgetData")
    }
}

// MARK: - Timeline Provider
struct VizanciaTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> VizanciaWidgetEntry {
        VizanciaWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (VizanciaWidgetEntry) -> Void) {
        completion(VizanciaWidgetEntry(date: Date(), data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VizanciaWidgetEntry>) -> Void) {
        let data = VizanciaWidgetData.load()
        let entry = VizanciaWidgetEntry(date: Date(), data: data)
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct VizanciaWidgetEntry: TimelineEntry {
    let date: Date
    let data: VizanciaWidgetData
}

// MARK: - Small Widget (Streak + XP)
struct SmallWidgetView: View {
    let entry: VizanciaWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("mascot_waving")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                Spacer()
                if entry.data.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(entry.data.currentStreak)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            Text("\(entry.data.totalXP)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("Total XP")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // Daily goal progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue.opacity(0.15))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(entry.data.dailyGoalMet ? Color.green : Color.blue)
                        .frame(width: geo.size.width * min(1, Double(entry.data.todayXP) / Double(max(entry.data.dailyXPGoal, 1))))
                }
            }
            .frame(height: 4)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Medium Widget (Full Dashboard)
struct MediumWidgetView: View {
    let entry: VizanciaWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side — Mascot + Greeting
            VStack(alignment: .leading, spacing: 6) {
                Image("mascot_waving")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)

                Spacer()

                Text("Level \(entry.data.currentLevel)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(entry.data.levelTitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right side — Stats
            VStack(alignment: .trailing, spacing: 8) {
                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("\(entry.data.currentStreak) day\(entry.data.currentStreak == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }

                // XP
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text("\(entry.data.totalXP) XP")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Daily Goal
                VStack(alignment: .trailing, spacing: 3) {
                    Text(entry.data.dailyGoalMet ? "Goal Met! ✅" : "\(entry.data.todayXP)/\(entry.data.dailyXPGoal) XP")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(entry.data.dailyGoalMet ? .green : .secondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.blue.opacity(0.15))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(entry.data.dailyGoalMet ? Color.green : Color.blue)
                                .frame(width: geo.size.width * min(1, Double(entry.data.todayXP) / Double(max(entry.data.dailyXPGoal, 1))))
                        }
                    }
                    .frame(height: 4)
                }

                // Review nudge
                if !entry.data.hasCompletedDailyChallenge {
                    Text("⭐ Daily Challenge waiting!")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Lock Screen Widget (Inline)
struct LockScreenStreakWidget: View {
    let entry: VizanciaWidgetEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(entry.data.currentStreak)")
            Text("•")
            Text("\(entry.data.totalXP) XP")
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
    }
}

// MARK: - Lock Screen Widget (Circular)
struct LockScreenCircularWidget: View {
    let entry: VizanciaWidgetEntry

    var body: some View {
        Gauge(value: min(1, Double(entry.data.todayXP) / Double(max(entry.data.dailyXPGoal, 1)))) {
            Image(systemName: "flame.fill")
        } currentValueLabel: {
            Text("\(entry.data.currentStreak)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - Widget Bundle
@main
struct VizanciaWidgetBundle: WidgetBundle {
    var body: some Widget {
        VizanciaStreakWidget()
        VizanciaDashboardWidget()
        VizanciaLockScreenWidget()
    }
}

// MARK: - Streak Widget (Small)
struct VizanciaStreakWidget: Widget {
    let kind: String = "VizanciaStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VizanciaTimelineProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Vizancia Streak")
        .description("Track your learning streak and XP")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Dashboard Widget (Medium)
struct VizanciaDashboardWidget: Widget {
    let kind: String = "VizanciaDashboardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VizanciaTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Vizancia Dashboard")
        .description("Your full learning dashboard at a glance")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Lock Screen Widget
struct VizanciaLockScreenWidget: Widget {
    let kind: String = "VizanciaLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VizanciaTimelineProvider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                LockScreenCircularWidget(entry: entry)
            }
        }
        .configurationDisplayName("Vizancia Streak")
        .description("Your streak on the Lock Screen")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}
