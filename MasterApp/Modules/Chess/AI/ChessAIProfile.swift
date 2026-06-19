import Foundation

struct ChessAIProfile {
    let searchDepth: Int
    let candidateCount: Int
    let randomness: Int

    nonisolated init(rating: Int) {
        switch rating {
        case ..<700:
            self.searchDepth = 1
            self.candidateCount = 6
            self.randomness = 220
        case ..<900:
            self.searchDepth = 1
            self.candidateCount = 4
            self.randomness = 140
        case ..<1200:
            self.searchDepth = 2
            self.candidateCount = 3
            self.randomness = 80
        case ..<1600:
            self.searchDepth = 2
            self.candidateCount = 2
            self.randomness = 35
        case ..<1800:
            self.searchDepth = 3
            self.candidateCount = 2
            self.randomness = 0
        case ..<2000:
            self.searchDepth = 3
            self.candidateCount = 1
            self.randomness = 0
        case ..<2200:
            self.searchDepth = 4
            self.candidateCount = 1
            self.randomness = 0
        default:
            self.searchDepth = 5
            self.candidateCount = 1
            self.randomness = 0
        }
    }
}
