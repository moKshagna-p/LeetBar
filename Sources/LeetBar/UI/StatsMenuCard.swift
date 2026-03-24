import SwiftUI

struct StatsMenuCard: View {
    let summary: DashboardSummary
    let profileImageURL: URL?
    @Binding var hoveredMetricID: String?

    private var selectedMetric: DifficultyMetric {
        summary.selectedMetric(hoveredID: hoveredMetricID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()
                ProfileAvatar(url: profileImageURL)
            }

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

private struct ProfileAvatar: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                LeetRemoteImage(urls: [url], contentMode: .fill) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
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
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
#if os(macOS)
        .onHover { hovering in
            onHoverChange(hovering)
        }
#endif
    }
}
