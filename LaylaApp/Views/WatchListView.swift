import SwiftUI
import SwiftData

struct WatchListView: View {
    @Query private var savedMovies: [SavedMovie]
    @Environment(\.modelContext) private var modelContext
    
    var watchedMovies: [SavedMovie] { savedMovies.filter { $0.isWatched } }
    var unwatchedMovies: [SavedMovie] { savedMovies.filter { !$0.isWatched } }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if savedMovies.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Inga sparade filmer än")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        if !unwatchedMovies.isEmpty {
                            Section {
                                ForEach(unwatchedMovies) { movie in
                                    MovieRowView(movie: movie)
                                }
                                .onDelete { indexSet in
                                    deleteMovies(from: unwatchedMovies, at: indexSet)
                                }
                            } header: {
                                Text("Vill se")
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        if !watchedMovies.isEmpty {
                            Section {
                                ForEach(watchedMovies) { movie in
                                    MovieRowView(movie: movie)
                                }
                                .onDelete { indexSet in
                                    deleteMovies(from: watchedMovies, at: indexSet)
                                }
                            } header: {
                                Text("Sedd")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Min Lista 🌙")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    func deleteMovies(from list: [SavedMovie], at indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(list[index])
        }
    }
}

struct MovieRowView: View {
    @Bindable var movie: SavedMovie
    
    var body: some View {
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
            
            Spacer()
            
            Button(action: { movie.isWatched.toggle() }) {
                Image(systemName: movie.isWatched ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(movie.isWatched ? .green : .gray)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.gray.opacity(0.1))
    }
}

#Preview {
    WatchListView()
        .preferredColorScheme(.dark)
}
