import Foundation

struct Room: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var venue: String
    var completionTime: String
    var outcome: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), venue: String, completionTime: String, outcome: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.venue = venue
        self.completionTime = completionTime
        self.outcome = outcome
        self.rating = rating
    }
}
