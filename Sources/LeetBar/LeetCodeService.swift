import Foundation

@MainActor
class LeetCodeService: ObservableObject {
    @Published var userStats: [SubmissionNum] = []
    @Published var totalCounts: [QuestionCount] = []
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
            } else {
                errorMessage = "User '\(username)' not found."
                userStats = []
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            userStats = []
        }
        
        isLoading = false
    }
}
