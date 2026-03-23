import SwiftUI

struct StatsMenuCard: View {
    let providerName: String
    let summary: DashboardSummary
    @Binding var hoveredMetricID: String?

    private var selectedMetric: DifficultyMetric {
        summary.selectedMetric(hoveredID: hoveredMetricID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(providerName)
                    .font(.headline)
                Spacer()
                Text(summary.accountLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(summary.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LeetDifficultyGaugeView(
                metric: selectedMetric,
                metrics: summary.difficultyMetrics,
                currentStreak: summary.currentStreak,
                longestStreak: summary.longestStreak
            )
            .frame(height: 158)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(summary.difficultyMetrics) { metric in
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
    let metric: DifficultyMetric
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
