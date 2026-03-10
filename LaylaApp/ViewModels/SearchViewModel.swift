import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Movie] = []
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.searchResults = []
                    return
                }
                Task {
                    await self?.search(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) async {
        isLoading = true
        do {
            searchResults = try await MovieService.shared.searchMovies(query: query)
        } catch {
            searchResults = []
        }
        isLoading = false
    }
}
