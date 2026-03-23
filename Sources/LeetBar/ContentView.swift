import SwiftUI

struct ContentView: View {
    @StateObject private var service = LeetCodeService()
    @AppStorage("username") private var username: String = ""
    @FocusState private var isFocused: Bool

    @State private var animate = false

    var body: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                GlassEffectContainer(spacing: 20) {
                    mainLayout
                }
            } else {
                mainLayout
            }
        }
        .frame(width: 320, height: 480)
        .background(backgroundView)
        .onAppear {
            animate = true
            if !username.isEmpty {
                Task { await service.fetchStats(username: username) }
            } else {
                isFocused = true
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
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)

                    TextField("Username", text: $username)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .font(.system(.body, design: .rounded))
                        .onSubmit {
                            Task { await service.fetchStats(username: username) }
                        }

                    if service.isLoading {
                        ProgressView().scaleEffect(0.5)
                    } else {
                        refreshButton
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .panelSurface(cornerRadius: 14, interactive: true)

                if let error = service.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red.opacity(0.8))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding([.horizontal, .top], 20)

            if !service.userStats.isEmpty {
                ScrollView {
                    VStack(spacing: 14) {
                        StatsMenuCard(
                            providerName: "LeetCode",
                            accountLabel: username.isEmpty ? "profile" : "@\(username)",
                            subtitle: "\(allSolved)/\(allTotal) solved",
                            metrics: metricRows)
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            } else if !service.isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text("Ready to Track Progress?")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("Enter your LeetCode username above")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary.opacity(0.7))
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }

            Divider().opacity(0.1)

            HStack {
                quitButton

                Spacer()

                Text("LeetBar v1.1")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var backgroundView: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).opacity(0.8)

            Group {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .offset(x: animate ? 100 : -100, y: animate ? -150 : 150)

                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .offset(x: animate ? -120 : 120, y: animate ? 120 : -120)

                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .offset(x: animate ? 50 : -50, y: animate ? 50 : -50)
            }
            .blur(radius: 60)
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)

            Rectangle()
                .fill(.ultraThinMaterial)
        }
    }

    private var refreshButton: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                Button {
                    Task { await service.fetchStats(username: username) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                        .symbolEffect(.bounce, value: service.isLoading)
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    Task { await service.fetchStats(username: username) }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)
                        .symbolEffect(.bounce, value: service.isLoading)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary.opacity(0.8))
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
                .font(.system(.caption, design: .rounded).bold())
            } else {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(.caption, design: .rounded).bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.white.opacity(0.05))
                .clipShape(Capsule())
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
    let metrics: [LeetMetric]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(providerName)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(accountLabel)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                ForEach(metrics) { metric in
                    LeetMetricRow(metric: metric)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .panelSurface(cornerRadius: 18)
    }
}

private struct LeetMetricRow: View {
    let metric: LeetMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(metric.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(metric.tint)
                Spacer()
                Text("\(metric.solved)/\(metric.total)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text("\(Int(metric.percentage * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 36, alignment: .trailing)
            }

            CompactProgressBar(progress: metric.percentage, tint: metric.tint)
        }
    }
}

private struct CompactProgressBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * max(0, min(progress, 1))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.22))
                Capsule()
                    .fill(tint)
                    .frame(width: width)
            }
        }
        .frame(height: 7)
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
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}
