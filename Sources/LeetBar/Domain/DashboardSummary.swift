import SwiftUI

enum LeetDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .all: return "Overall"
        }
    }

    var apiLabel: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .all: return "All"
        }
    }

    var tint: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .all: return .accentColor
        }
    }
}

struct DifficultyMetric: Identifiable, Equatable {
    let difficulty: LeetDifficulty
    let solved: Int
    let total: Int

    var id: String { difficulty.id }
    var title: String { difficulty.title }
    var tint: Color { difficulty.tint }

    var percentage: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(solved) / Double(total), 0), 1)
    }
}

struct DashboardSummary {
    let accountLabel: String
    let allMetric: DifficultyMetric
    let difficultyMetrics: [DifficultyMetric]
    let currentStreak: Int
    let longestStreak: Int

    var subtitle: String {
        "\(allMetric.solved) of \(allMetric.total) solved"
    }

    var completionPercent: Int {
        Int((allMetric.percentage * 100).rounded())
    }

    var remainingCount: Int {
        max(allMetric.total - allMetric.solved, 0)
    }

    var easyMediumSolved: Int {
        difficultyMetrics
            .filter { $0.difficulty == .easy || $0.difficulty == .medium }
            .reduce(0) { $0 + $1.solved }
    }

    var bestSegment: DifficultyMetric {
        difficultyMetrics.max(by: { $0.percentage < $1.percentage }) ?? allMetric
    }

    func selectedMetric(hoveredID: String?) -> DifficultyMetric {
        guard let hoveredID,
              let hovered = difficultyMetrics.first(where: { $0.id == hoveredID }) else {
            return allMetric
        }
        return hovered
    }

    static func build(
        username: String,
        userStats: [SubmissionNum],
        totalCounts: [QuestionCount],
        currentStreak: Int,
        longestStreak: Int
    ) -> DashboardSummary {
        func solved(for difficulty: LeetDifficulty) -> Int {
            userStats.first(where: { $0.difficulty == difficulty.apiLabel })?.count ?? 0
        }

        func total(for difficulty: LeetDifficulty) -> Int {
            max(totalCounts.first(where: { $0.difficulty == difficulty.apiLabel })?.count ?? 1, 1)
        }

        let all = DifficultyMetric(difficulty: .all, solved: solved(for: .all), total: total(for: .all))
        let rows = [LeetDifficulty.easy, .medium, .hard].map {
            DifficultyMetric(difficulty: $0, solved: solved(for: $0), total: total(for: $0))
        }

        return DashboardSummary(
            accountLabel: username.isEmpty ? "profile" : "@\(username)",
            allMetric: all,
            difficultyMetrics: rows,
            currentStreak: currentStreak,
            longestStreak: longestStreak
        )
    }
}
