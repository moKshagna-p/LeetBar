import SwiftUI

struct ContentView: View {
    @StateObject private var service = LeetCodeService()
    @AppStorage("username") private var username: String = ""
    @FocusState private var isFocused: Bool

    @State private var animate = false
    @State private var hoveredDifficultyID: String?

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
        .frame(width: 420, height: 660)
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
            VStack(spacing: 14) {
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
            .padding(.horizontal, 24)
            .padding(.top, 24)

            if !service.userStats.isEmpty {
                VStack(spacing: 0) {
                    StatsMenuCard(
                        providerName: "LeetCode",
                        accountLabel: username.isEmpty ? "profile" : "@\(username)",
                        subtitle: "\(allSolved)/\(allTotal) solved",
                        allSolved: allSolved,
                        allTotal: allTotal,
                        currentStreak: service.currentStreak,
                        longestStreak: service.longestStreak,
                        metrics: metricRows,
                        hoveredMetricID: $hoveredDifficultyID
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                    Spacer(minLength: 0)
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
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }

    private var backgroundView: some View {
        ZStack {
            // Native-like translucent base, similar to menubar popovers.
            Rectangle()
                .fill(.regularMaterial.opacity(0.88))

            Group {
                Circle()
                    .fill(Color(nsColor: .systemBlue).opacity(0.12))
                    .frame(width: 260, height: 260)
                    .offset(x: animate ? 90 : -80, y: animate ? -130 : 110)

                Circle()
                    .fill(Color(nsColor: .systemIndigo).opacity(0.1))
                    .frame(width: 320, height: 320)
                    .offset(x: animate ? -110 : 120, y: animate ? 110 : -100)

                Circle()
                    .fill(Color(nsColor: .systemTeal).opacity(0.08))
                    .frame(width: 200, height: 200)
                    .offset(x: animate ? 45 : -40, y: animate ? 35 : -40)
            }
            .blur(radius: 72)
            .animation(.easeInOut(duration: 14).repeatForever(autoreverses: true), value: animate)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.08),
                            .clear,
                            .black.opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
                .padding(1)
        )
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
    let allSolved: Int
    let allTotal: Int
    let currentStreak: Int
    let longestStreak: Int
    let metrics: [LeetMetric]
    @Binding var hoveredMetricID: String?

    private var totalMetric: LeetMetric {
        LeetMetric(id: "all", title: "All", solved: allSolved, total: allTotal, tint: Color(red: 0.20, green: 0.78, blue: 0.86))
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

            LeetDifficultyGaugeView(
                metric: selectedMetric,
                allSolved: allSolved,
                allTotal: allTotal,
                currentStreak: currentStreak,
                longestStreak: longestStreak
            )
            .frame(height: 220)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(metrics) { metric in
                    LeetMetricRow(
                        metric: metric,
                        isActive: metric.id == hoveredMetricID,
                        onHoverChange: { hovering in
                            withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.86, blendDuration: 0.12)) {
                                hoveredMetricID = hovering ? metric.id : nil
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .panelSurface(cornerRadius: 18)
    }
}

private struct LeetMetricRow: View {
    let metric: LeetMetric
    let isActive: Bool
    let onHoverChange: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isActive ? .white.opacity(0.07) : .clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
#if os(macOS)
        .onHover { hovering in
            onHoverChange(hovering)
        }
#endif
    }
}

private struct LeetDifficultyGaugeView: View {
    let metric: LeetMetric
    let allSolved: Int
    let allTotal: Int
    let currentStreak: Int
    let longestStreak: Int

    private let startAngle = Angle.degrees(142)
    private let sweepAngle = 258.0

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth: CGFloat = 10
            let radius = side * 0.5 - lineWidth
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let endAngle = Angle.degrees(startAngle.degrees + (sweepAngle * metric.percentage))

            ZStack {
                GaugeArcShape(startAngle: startAngle, endAngle: .degrees(startAngle.degrees + sweepAngle))
                    .stroke(.white.opacity(0.16), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                GaugeArcShape(startAngle: startAngle, endAngle: endAngle)
                    .stroke(metric.tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .shadow(color: metric.tint.opacity(0.25), radius: 5, x: 0, y: 1)
                    .animation(.interactiveSpring(response: 0.48, dampingFraction: 0.84, blendDuration: 0.2), value: metric.percentage)
                    .animation(.easeInOut(duration: 0.22), value: metric.id)

                Circle()
                    .fill(.white.opacity(0.35))
                    .frame(width: 8, height: 8)
                    .position(point(center: center, radius: radius, angle: startAngle))

                Circle()
                    .fill(metric.tint)
                    .frame(width: 10, height: 10)
                    .shadow(color: metric.tint.opacity(0.5), radius: 4, x: 0, y: 0)
                    .position(point(center: center, radius: radius, angle: endAngle))
                    .animation(.interactiveSpring(response: 0.48, dampingFraction: 0.84, blendDuration: 0.2), value: metric.percentage)

                VStack(spacing: 3) {
                    Text(metric.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.96))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(metric.solved)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text("/\(metric.total)")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Text("Solved")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .animation(.interactiveSpring(response: 0.45, dampingFraction: 0.86), value: metric.id)
            }

            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Label("\(currentStreak)d current", systemImage: "flame.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange.opacity(0.95))
                    Label("\(longestStreak)d best", systemImage: "trophy.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.yellow.opacity(0.95))
                }
                .padding(.bottom, 4)
            }
        }
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        let radians = CGFloat(angle.radians)
        return CGPoint(
            x: center.x + CoreGraphics.cos(radians) * radius,
            y: center.y + CoreGraphics.sin(radians) * radius
        )
    }
}

private struct GaugeArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 10
        let arcRect = rect.insetBy(dx: inset, dy: inset)
        let center = CGPoint(x: arcRect.midX, y: arcRect.midY)
        let radius = min(arcRect.width, arcRect.height) / 2

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
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
                    .animation(.easeInOut(duration: 0.22), value: progress)
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
                .background(.regularMaterial.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                )
        }
    }
}
