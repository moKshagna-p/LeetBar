import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var service = LeetCodeService()
    @AppStorage("username") private var username: String = ""
    @FocusState private var isFocused: Bool

    @State private var hoveredDifficultyID: String?
    @State private var statsVisible = false

    private var summary: DashboardSummary {
        DashboardSummary.build(
            username: username,
            userStats: service.userStats,
            totalCounts: service.totalCounts,
            currentStreak: service.currentStreak,
            longestStreak: service.longestStreak
        )
    }

    var body: some View {
        mainLayout
        .rootVisualContainer(spacing: 16)
        .frame(width: 368, height: 560)
        .onAppear {
            if !username.isEmpty {
                fetchStats()
            } else {
                isFocused = true
            }
            withAnimation(.easeOut(duration: 0.35)) {
                statsVisible = true
            }
        }
    }

    private var mainLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            AccountInputBar(
                username: $username,
                isLoading: service.isLoading,
                onRefresh: fetchStats,
                isFocused: $isFocused
            )

            if let error = service.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }

            contentState
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            HStack {
                Spacer()
                QuitButton()
            }
            .padding(.top, 2)
        }
        .padding(18)
        .opacity(statsVisible ? 1 : 0)
        .offset(y: statsVisible ? 0 : 6)
        .animation(.smooth(duration: 0.28), value: service.userStats)
        .animation(.smooth(duration: 0.22), value: service.isLoading)
        .animation(.easeOut(duration: 0.3), value: statsVisible)
    }

    @ViewBuilder
    private var contentState: some View {
        if !service.userStats.isEmpty {
            ScrollView {
                VStack(spacing: 12) {
                    StatsMenuCard(
                        summary: summary,
                        profileImageURL: service.profileImageURL,
                        hoveredMetricID: $hoveredDifficultyID
                    )

                    InsightsPanel(badges: service.badges)
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
        } else if !service.isLoading {
            ContentUnavailableView(
                "No Stats Yet",
                systemImage: "chart.bar.xaxis",
                description: Text("Enter your username above to load your solved counts and streaks.")
            )
            .panelSurface(cornerRadius: 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        } else {
            VStack {
                Spacer()
                ProgressView("Fetching stats…")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        }
    }

    private func fetchStats() {
        Task {
            await service.fetchStats(username: username)
        }
    }
}

private struct QuitButton: View {
    var body: some View {
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .leetBarButtonStyle()
    }
}
