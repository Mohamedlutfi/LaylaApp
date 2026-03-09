import Foundation

class MovieService {
    static let shared = MovieService()
    private let apiKey = "7b1aa0f008498fc8dd16d520d8750e28"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchTrending() async throws -> [Movie] {
        let url = URL(string: "\(baseURL)/trending/movie/week?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }
    
    func searchMovies(query: String) async throws -> [Movie] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }
    
    func fetchTopRated() async throws -> [Movie] {
        let url = URL(string: "\(baseURL)/movie/top_rated?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        let url = URL(string: "\(baseURL)/movie/\(id)?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Movie.self, from: data)
    }
    
    func fetchCredits(id: Int) async throws -> [CastMember] {
        let url = URL(string: "\(baseURL)/movie/\(id)/credits?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Credits.self, from: data).cast
    }
    
    func fetchVideos(id: Int) async throws -> [Video] {
        let url = URL(string: "\(baseURL)/movie/\(id)/videos?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(VideoResponse.self, from: data).results
    }
}
