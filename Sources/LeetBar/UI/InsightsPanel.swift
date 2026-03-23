import SwiftUI

struct InsightsPanel: View {
    let summary: DashboardSummary

    var body: some View {
        let tiles: [(String, String, String)] = [
            ("chart.pie", "Completion", "\(summary.completionPercent)%"),
            ("tray.full", "Remaining", "\(summary.remainingCount)"),
            ("bolt", "Easy + Medium", "\(summary.easyMediumSolved)"),
            ("scope", "Best Segment", summary.bestSegment.title),
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
