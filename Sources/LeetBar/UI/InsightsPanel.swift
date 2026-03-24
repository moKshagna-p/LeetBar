import SwiftUI

struct InsightsPanel: View {
    let badges: [LeetBadge]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Badges")
                    .font(.headline)
                Spacer()
            }

            if badges.isEmpty {
                ContentUnavailableView(
                    "No Badges Yet",
                    systemImage: "medal",
                    description: Text("Earn LeetCode badges and they will appear here.")
                )
                .panelSurface(cornerRadius: 14)
            } else {
                HStack(spacing: 14) {
                    Spacer(minLength: 0)
                    ForEach(recentBadges) { badge in
                        FeaturedBadgeIcon(badge: badge)
                            .help(badge.name)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var recentBadges: [LeetBadge] {
        Array(badges.prefix(3))
    }
}

private struct FeaturedBadgeIcon: View {
    let badge: LeetBadge

    var body: some View {
        BadgeIcon(primaryURL: badge.iconURL, fallbackURL: badge.fallbackIconURL, size: 78)
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.clear)
            )
    }
}

private struct BadgeIcon: View {
    let primaryURL: URL?
    let fallbackURL: URL?
    let size: CGFloat

    var body: some View {
        LeetRemoteImage(urls: candidateURLs, contentMode: .fit) {
            fallback
        }
        .frame(width: size, height: size)
    }

    private var candidateURLs: [URL] {
        [primaryURL, fallbackURL].compactMap { $0 }
    }

    private var fallback: some View {
        Image(systemName: "seal.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
    }
}
