import Foundation
import SwiftData

@Model
class WatchList {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var movies: [SavedMovie]
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.movies = []
    }
}
