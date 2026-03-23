import Foundation

struct GraphQLRequest: Codable {
    let query: String
    let variables: [String: String]
}

struct LeetCodeResponse: Codable {
    let data: LeetCodeData
}

struct LeetCodeData: Codable {
    let allQuestionsCount: [QuestionCount]
    let matchedUser: MatchedUser?
}

struct QuestionCount: Codable, Hashable {
    let difficulty: String
    let count: Int
}

struct MatchedUser: Codable {
    let username: String
    let submitStats: SubmitStats
}

struct SubmitStats: Codable {
    let acSubmissionNum: [SubmissionNum]
}

struct SubmissionNum: Codable, Hashable {
    let difficulty: String
    let count: Int
}
