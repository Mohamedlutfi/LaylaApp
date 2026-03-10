import Foundation
import Combine

@MainActor
class MovieViewModel: ObservableObject {
    @Published var trendingMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadMovies() async {
        isLoading = true
        errorMessage = nil
        do {
            async let trending = MovieService.shared.fetchTrending()
            async let topRated = MovieService.shared.fetchTopRated()
            trendingMovies = try await trending
            topRatedMovies = try await topRated
        } catch {
            errorMessage = "Kunde inte hämta filmer"
        }
        isLoading = false
    }
}
