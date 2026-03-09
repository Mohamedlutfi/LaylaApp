import Foundation
import SwiftData

@Model
class SavedMovie {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var voteAverage: Double
    var voteCount: Int
    var releaseDate: String?
    var runtime: Int
    var genreNames: [String]
    var isWatched: Bool
    var watchList: WatchList?
    
    init(id: Int, title: String, overview: String, posterPath: String? = nil, voteAverage: Double, voteCount: Int = 0, releaseDate: String? = nil, runtime: Int = 0, genreNames: [String] = []) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.genreNames = genreNames
        self.isWatched = false
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var runtimeText: String {
        guard runtime > 0 else { return "Okänd" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
