import Foundation

@MainActor
class LeetCodeService: ObservableObject {
    @Published var userStats: [SubmissionNum] = []
    @Published var totalCounts: [QuestionCount] = []
    @Published var currentStreak = 0
    @Published var longestStreak = 0
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchStats(username: String) async {
        guard !username.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://leetcode.com/graphql/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // LeetCode sometimes requires Referer to avoid 403
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        
        let query = """
        query getUserProfile($username: String!) {
          allQuestionsCount {
            difficulty
            count
          }
          matchedUser(username: $username) {
            username
            submitStats: submitStatsGlobal {
              acSubmissionNum {
                difficulty
                count
              }
            }
          }
        }
        """
        
        let reqBody = GraphQLRequest(query: query, variables: ["username": username])
        
        do {
            request.httpBody = try JSONEncoder().encode(reqBody)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(LeetCodeResponse.self, from: data)
            
            self.totalCounts = decoded.data.allQuestionsCount
            
            if let acStats = decoded.data.matchedUser?.submitStats.acSubmissionNum {
                self.userStats = acStats
                await self.fetchStreaks(username: username)
            } else {
                errorMessage = "User '\(username)' not found."
                userStats = []
                currentStreak = 0
                longestStreak = 0
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            userStats = []
            currentStreak = 0
            longestStreak = 0
        }
        
        isLoading = false
    }

    private func fetchStreaks(username: String) async {
        let url = URL(string: "https://leetcode.com/graphql/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")

        let query = """
        query getCalendar($username: String!) {
          matchedUser(username: $username) {
            userCalendar {
              submissionCalendar
            }
          }
        }
        """

        let reqBody = GraphQLRequest(query: query, variables: ["username": username])

        do {
            request.httpBody = try JSONEncoder().encode(reqBody)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(LeetCodeCalendarResponse.self, from: data)

            guard let rawCalendar = decoded.data?.matchedUser?.userCalendar?.submissionCalendar,
                  let streaks = self.computeStreaks(from: rawCalendar)
            else {
                self.currentStreak = 0
                self.longestStreak = 0
                return
            }

            self.currentStreak = streaks.current
            self.longestStreak = streaks.longest
        } catch {
            self.currentStreak = 0
            self.longestStreak = 0
        }
    }

    private func computeStreaks(from submissionCalendar: String) -> (current: Int, longest: Int)? {
        guard let data = submissionCalendar.data(using: .utf8) else { return nil }
        guard let rawMap = try? JSONDecoder().decode([String: Int].self, from: data) else { return nil }

        let calendar = Calendar.current
        let activeDays: Set<Date> = Set(
            rawMap.compactMap { (timestamp, count) in
                guard count > 0, let epoch = TimeInterval(timestamp) else { return nil }
                return calendar.startOfDay(for: Date(timeIntervalSince1970: epoch))
            }
        )

        guard !activeDays.isEmpty else { return (0, 0) }

        let sortedDays = activeDays.sorted()
        var longest = 1
        var running = 1
        for index in 1..<sortedDays.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: sortedDays[index - 1]),
               calendar.isDate(sortedDays[index], inSameDayAs: expected) {
                running += 1
            } else {
                longest = max(longest, running)
                running = 1
            }
        }
        longest = max(longest, running)

        let today = calendar.startOfDay(for: Date())
        var cursor = today
        if !activeDays.contains(cursor),
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           activeDays.contains(yesterday) {
            cursor = yesterday
        }

        var current = 0
        while activeDays.contains(cursor) {
            current += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return (current, longest)
    }
}
