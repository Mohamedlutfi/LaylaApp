import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Trending sektion
                        Text("🔥 Trending")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.trendingMovies) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        MovieCardView(movie: movie)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Top Rated sektion
                        Text("⭐ Top Rated")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.topRatedMovies) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        MovieCardView(movie: movie)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Layla 🌙")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadMovies()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.purple)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
