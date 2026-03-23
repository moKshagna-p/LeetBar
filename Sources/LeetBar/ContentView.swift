import SwiftUI

struct ContentView: View {
    @StateObject private var service = LeetCodeService()
    @AppStorage("username") private var username: String = ""
    @FocusState private var isFocused: Bool

    @State private var hoveredDifficultyID: String?
    @State private var statsVisible = false

    var body: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                GlassEffectContainer(spacing: 16) {
                    mainLayout
                }
            } else {
                mainLayout
            }
        }
        .frame(width: 368, height: 560)
        .onAppear {
            if !username.isEmpty {
                Task { await service.fetchStats(username: username) }
            } else {
                isFocused = true
            }
            withAnimation(.easeOut(duration: 0.35)) {
                statsVisible = true
            }
        }
    }

    private var allSolved: Int {
        solvedCount("All")
    }

    private var allTotal: Int {
        totalCount("All")
    }

    private var metricRows: [LeetMetric] {
        [
            LeetMetric(id: "easy", title: "Easy", solved: solvedCount("Easy"), total: totalCount("Easy"), tint: .green),
            LeetMetric(id: "medium", title: "Medium", solved: solvedCount("Medium"), total: totalCount("Medium"), tint: .orange),
            LeetMetric(id: "hard", title: "Hard", solved: solvedCount("Hard"), total: totalCount("Hard"), tint: .red),
        ]
    }

    private func solvedCount(_ difficulty: String) -> Int {
        service.userStats.first(where: { $0.difficulty == difficulty })?.count ?? 0
    }

    private func totalCount(_ difficulty: String) -> Int {
        max(service.totalCounts.first(where: { $0.difficulty == difficulty })?.count ?? 1, 1)
    }

    private var mainLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle")
                        .foregroundStyle(.secondary)

                    TextField("LeetCode username", text: $username)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .onSubmit {
                            Task { await service.fetchStats(username: username) }
                        }

                    if service.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        refreshButton
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .panelSurface(cornerRadius: 14, interactive: true)

                if let error = service.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }

            Group {
                if !service.userStats.isEmpty {
                    ScrollView {
                        VStack(spacing: 12) {
                            StatsMenuCard(
                                providerName: "LeetCode",
                                accountLabel: username.isEmpty ? "profile" : "@\(username)",
                                subtitle: "\(allSolved) of \(allTotal) solved",
                                allSolved: allSolved,
                                allTotal: allTotal,
                                currentStreak: service.currentStreak,
                                longestStreak: service.longestStreak,
                                metrics: metricRows,
                                hoveredMetricID: $hoveredDifficultyID
                            )

                            InsightsPanel(
                                allSolved: allSolved,
                                allTotal: allTotal,
                                metrics: metricRows
                            )
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            HStack {
                Spacer()
                quitButton
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

    private var refreshButton: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                Button {
                    Task { await service.fetchStats(username: username) }
                } label: {
                    Label("Refresh stats", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glassProminent)
                .symbolEffect(.rotate.byLayer, value: service.isLoading)
                .help("Refresh stats")
            } else {
                Button {
                    Task { await service.fetchStats(username: username) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var quitButton: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.glass)
            } else {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct LeetMetric: Identifiable {
    let id: String
    let title: String
    let solved: Int
    let total: Int
    let tint: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(solved) / Double(total), 0), 1)
    }
}

private struct StatsMenuCard: View {
    let providerName: String
    let accountLabel: String
    let subtitle: String
    let allSolved: Int
    let allTotal: Int
    let currentStreak: Int
    let longestStreak: Int
    let metrics: [LeetMetric]
    @Binding var hoveredMetricID: String?

    private var totalMetric: LeetMetric {
        LeetMetric(id: "all", title: "All", solved: allSolved, total: allTotal, tint: .accentColor)
    }

    private var selectedMetric: LeetMetric {
        if let hoveredMetricID, let hovered = metrics.first(where: { $0.id == hoveredMetricID }) {
            return hovered
        }
        return totalMetric
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(providerName)
                    .font(.headline)
                Spacer()
                Text(accountLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LeetDifficultyGaugeView(
                metric: selectedMetric,
                metrics: metrics,
                currentStreak: currentStreak,
                longestStreak: longestStreak
            )
            .frame(height: 158)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(metrics) { metric in
                    LeetMetricRow(
                        metric: metric,
                        isActive: metric.id == hoveredMetricID,
                        onHoverChange: { hovering in
                            withAnimation(.easeInOut(duration: 0.18)) {
                                hoveredMetricID = hovering ? metric.id : nil
                            }
                        }
                    )
                }
            }
        }
        .padding(16)
    }
}

private struct LeetMetricRow: View {
    let metric: LeetMetric
    let isActive: Bool
    let onHoverChange: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(metric.title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(metric.solved)/\(metric.total)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: metric.percentage)
                .tint(metric.tint)
                .controlSize(.small)
                .scaleEffect(x: 1, y: 0.72, anchor: .center)
                .animation(.smooth(duration: 0.2), value: metric.percentage)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isActive ? Color.primary.opacity(0.05) : Color.primary.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isActive ? Color.primary.opacity(0.18) : Color.primary.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
#if os(macOS)
        .onHover { hovering in
            onHoverChange(hovering)
        }
#endif
    }
}

private struct InsightsPanel: View {
    let allSolved: Int
    let allTotal: Int
    let metrics: [LeetMetric]

    private var completionPercent: Int {
        guard allTotal > 0 else { return 0 }
        return Int((Double(allSolved) / Double(allTotal) * 100).rounded())
    }

    private var remainingCount: Int {
        max(allTotal - allSolved, 0)
    }

    private var easyMediumSolved: Int {
        metrics
            .filter { $0.id == "easy" || $0.id == "medium" }
            .reduce(0) { $0 + $1.solved }
    }

    private var bestSegment: LeetMetric {
        metrics.max(by: { $0.percentage < $1.percentage }) ?? LeetMetric(
            id: "all",
            title: "Overall",
            solved: allSolved,
            total: allTotal,
            tint: .accentColor
        )
    }

    var body: some View {
        let tiles: [(String, String, String)] = [
            ("chart.pie", "Completion", "\(completionPercent)%"),
            ("tray.full", "Remaining", "\(remainingCount)"),
            ("bolt", "Easy + Medium", "\(easyMediumSolved)"),
            ("scope", "Best Segment", bestSegment.title),
        ]

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(tiles, id: \.1) { icon, label, value in
                InsightTile(icon: icon, label: label, value: value)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

private struct InsightTile: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(label, systemImage: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

private struct LeetDifficultyGaugeView: View {
    let metric: LeetMetric
    let metrics: [LeetMetric]
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                SegmentedDifficultyRing(metrics: metrics, highlightedID: metric.id)
                    .frame(width: 126, height: 126)

                Text("\(metric.solved)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 96, alignment: .center)
                    .contentTransition(.numericText())
            }
            .padding(.bottom, 6)
            .animation(.spring(response: 0.4, dampingFraction: 0.82), value: metric.id)
            .animation(.spring(response: 0.4, dampingFraction: 0.82), value: metric.solved)

            (
                Text("\(metric.solved)")
                    .font(.title.weight(.bold))
                    .monospacedDigit()
                +
                Text(" / \(metric.total)")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            )
            .contentTransition(.numericText())

            HStack(spacing: 12) {
                Label("\(currentStreak)d current", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
                Label("\(longestStreak)d best", systemImage: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.caption)

            Label(
                metric.id == "all" ? "Overall" : metric.title,
                systemImage: metric.id == "all" ? "square.grid.2x2" : "scope"
            )
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 2)
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.16), value: metric.id)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SegmentedDifficultyRing: View {
    let metrics: [LeetMetric]
    let highlightedID: String

    private let orderedIDs = ["easy", "medium", "hard"]
    private let segmentGap: CGFloat = 0.035
    private let trackLineWidth: CGFloat = 8
    private let progressLineWidth: CGFloat = 5

    private func metric(for id: String) -> LeetMetric {
        metrics.first(where: { $0.id == id }) ?? LeetMetric(id: id, title: id.capitalized, solved: 0, total: 1, tint: .secondary)
    }

    var body: some View {
        let available: CGFloat = 1 - (segmentGap * 3)
        let segmentLength: CGFloat = available / 3

        ZStack {
            ForEach(Array(orderedIDs.enumerated()), id: \.offset) { index, id in
                let difficulty = metric(for: id)
                let start = CGFloat(index) * (segmentLength + segmentGap)
                let end = start + segmentLength
                let progressEnd = start + (segmentLength * max(0, min(difficulty.percentage, 1)))
                let isHighlighted = highlightedID == id || highlightedID == "all"

                Circle()
                    .trim(from: start, to: end)
                    .stroke(
                        difficulty.tint.opacity(isHighlighted ? 0.24 : 0.13),
                        style: StrokeStyle(lineWidth: trackLineWidth, lineCap: .round)
                    )

                if progressEnd > start + 0.0001 {
                    Circle()
                        .trim(from: start, to: progressEnd)
                        .stroke(
                            difficulty.tint,
                            style: StrokeStyle(lineWidth: progressLineWidth, lineCap: .round)
                        )
                }
            }
        }
        .rotationEffect(.degrees(-90))
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: metrics.map(\.percentage))
        .animation(.easeInOut(duration: 0.18), value: highlightedID)
    }
}

private extension View {
    @ViewBuilder
    func panelSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(macOS 26, iOS 26, *) {
            if interactive {
                self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
