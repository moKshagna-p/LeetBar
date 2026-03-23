import SwiftUI

struct LeetDifficultyGaugeView: View {
    let metric: DifficultyMetric
    let metrics: [DifficultyMetric]
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
                metric.difficulty == .all ? "Overall" : metric.title,
                systemImage: metric.difficulty == .all ? "square.grid.2x2" : "scope"
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
    let metrics: [DifficultyMetric]
    let highlightedID: String

    private let orderedDifficulty: [LeetDifficulty] = [.easy, .medium, .hard]
    private let segmentGap: CGFloat = 0.035
    private let trackLineWidth: CGFloat = 8
    private let progressLineWidth: CGFloat = 5

    private func metric(for difficulty: LeetDifficulty) -> DifficultyMetric {
        metrics.first(where: { $0.difficulty == difficulty }) ?? DifficultyMetric(difficulty: difficulty, solved: 0, total: 1)
    }

    var body: some View {
        let available: CGFloat = 1 - (segmentGap * 3)
        let segmentLength: CGFloat = available / 3

        ZStack {
            ForEach(Array(orderedDifficulty.enumerated()), id: \.offset) { index, difficulty in
                let current = metric(for: difficulty)
                let start = CGFloat(index) * (segmentLength + segmentGap)
                let end = start + segmentLength
                let progressEnd = start + (segmentLength * max(0, min(current.percentage, 1)))
                let isHighlighted = highlightedID == current.id || highlightedID == LeetDifficulty.all.id

                Circle()
                    .trim(from: start, to: end)
                    .stroke(
                        current.tint.opacity(isHighlighted ? 0.24 : 0.13),
                        style: StrokeStyle(lineWidth: trackLineWidth, lineCap: .round)
                    )

                if progressEnd > start + 0.0001 {
                    Circle()
                        .trim(from: start, to: progressEnd)
                        .stroke(
                            current.tint,
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
