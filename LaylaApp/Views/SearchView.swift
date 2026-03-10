import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    if viewModel.searchText.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Sök efter en film")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else if viewModel.isLoading {
                        ProgressView()
                            .tint(.purple)
                            .frame(maxHeight: .infinity)
                    } else {
                        List(viewModel.searchResults) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: movie.posterURL) { image in
                                        image.resizable().aspectRatio(2/3, contentMode: .fill)
                                    } placeholder: {
                                        Rectangle().fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 50, height: 75)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(movie.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text(String(format: "%.1f", movie.voteAverage))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.black)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Sök")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $viewModel.searchText, prompt: "Sök filmer...")
        }
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
