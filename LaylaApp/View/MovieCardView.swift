import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView().tint(.purple))
            }
            .frame(width: 130, height: 195)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(movie.title)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 130, alignment: .leading)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    MovieDetailView(movie: Movie(
        id: 238,
        title: "The Godfather",
        overview: "Spanning the years 1945 to 1955...",
        posterPath: nil,
        backdropPath: nil,
        voteAverage: 8.7,
        voteCount: 1000,
        releaseDate: "1972-03-14",
        genreIds: [18, 80],
        runtime: 175,
        genres: [Genre(id: 18, name: "Drama")]
    ))
    .preferredColorScheme(.dark)
}
