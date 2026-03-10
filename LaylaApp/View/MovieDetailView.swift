import SwiftUI
import SwiftData
import UserNotifications

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @Query private var savedMovies: [SavedMovie]
    
    @State private var details: Movie?
    @State private var cast: [CastMember] = []
    @State private var trailerURL: URL?
    @State private var showNotificationPicker = false
    @State private var notificationScheduled = false
    
    var isSaved: Bool {
        savedMovies.contains { $0.id == movie.id }
    }
    
    var displayMovie: Movie { details ?? movie }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Backdrop
                    AsyncImage(url: displayMovie.backdropURL) { image in
                        image.resizable().aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 220)
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Titel & spara
                        HStack {
                            Text(displayMovie.title)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: toggleSave) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.title2)
                                    .foregroundColor(isSaved ? .purple : .white)
                            }
                        }
                        
                        // Info rad
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").foregroundColor(.yellow)
                                Text(String(format: "%.1f", displayMovie.voteAverage))
                                    .foregroundColor(.white)
                            }
                            if let count = displayMovie.voteCount {
                                Text("(\(count) röster)")
                                    .foregroundColor(.gray)
                            }
                            if let date = displayMovie.releaseDate {
                                Text(date.prefix(4)).foregroundColor(.gray)
                            }
                            Text(displayMovie.runtimeText)
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        
                        // Genres
                        if let genres = displayMovie.genres, !genres.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(genres) { genre in
                                        Text(genre.name)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.purple.opacity(0.3))
                                            .foregroundColor(.purple)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        
                        // Trailer knapp
                        if let trailerURL {
                            Link(destination: trailerURL) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Se Trailer på YouTube")
                                        .bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        // Notifikation knapp
                        Button(action: { showNotificationPicker = true }) {
                            HStack {
                                Image(systemName: notificationScheduled ? "bell.fill" : "bell")
                                Text(notificationScheduled ? "Påminnelse satt! ✓" : "Påminn mig om den här filmen")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(notificationScheduled ? Color.green.opacity(0.3) : Color.purple.opacity(0.3))
                            .foregroundColor(notificationScheduled ? .green : .purple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .confirmationDialog("När vill du bli påmind?", isPresented: $showNotificationPicker) {
                            Button("Om 1 timme") { scheduleNotification(hours: 1) }
                            Button("Om 3 timmar") { scheduleNotification(hours: 3) }
                            Button("Ikväll kl 20:00") { scheduleNotificationAt(hour: 20) }
                            Button("Imorgon kl 18:00") { scheduleNotificationTomorrow() }
                            Button("Avbryt", role: .cancel) {}
                        }
                        
                        // Beskrivning
                        Text("Beskrivning")
                            .font(.headline).foregroundColor(.white)
                        Text(displayMovie.overview.isEmpty ? "Ingen beskrivning." : displayMovie.overview)
                            .font(.body).foregroundColor(.gray).lineSpacing(4)
                        
                        // Skådespelare
                        if !cast.isEmpty {
                            Text("Skådespelare")
                                .font(.headline).foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(cast.prefix(10)) { member in
                                        VStack(spacing: 6) {
                                            AsyncImage(url: member.profileURL) { image in
                                                image.resizable().aspectRatio(2/3, contentMode: .fill)
                                            } placeholder: {
                                                Rectangle().fill(Color.gray.opacity(0.3))
                                                    .overlay(Image(systemName: "person.fill")
                                                        .foregroundColor(.gray))
                                            }
                                            .frame(width: 80, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            
                                            Text(member.name)
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .frame(width: 80)
                                            
                                            Text(member.character)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                                .frame(width: 80)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            async let detailsResult = MovieService.shared.fetchMovieDetails(id: movie.id)
            async let castResult = MovieService.shared.fetchCredits(id: movie.id)
            async let videosResult = MovieService.shared.fetchVideos(id: movie.id)
            
            details = try? await detailsResult
            cast = (try? await castResult) ?? []
            let videos = (try? await videosResult) ?? []
            trailerURL = videos.first(where: { $0.type == "Trailer" })?.youtubeURL
        }
    }
    
    func toggleSave() {
        if let existing = savedMovies.first(where: { $0.id == movie.id }) {
            modelContext.delete(existing)
        } else {
            let saved = SavedMovie(
                id: displayMovie.id,
                title: displayMovie.title,
                overview: displayMovie.overview,
                posterPath: displayMovie.posterPath,
                voteAverage: displayMovie.voteAverage,
                voteCount: displayMovie.voteCount ?? 0,
                releaseDate: displayMovie.releaseDate,
                runtime: displayMovie.runtime ?? 0,
                genreNames: displayMovie.genres?.map { $0.name } ?? []
            )
            modelContext.insert(saved)
        }
    }
    
    func scheduleNotification(hours: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🎬 Dags att kolla!"
            content.body = "Du ville se \(movie.title) – starta filmen nu!"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hours * 3600), repeats: false)
            let request = UNNotificationRequest(identifier: "movie-\(movie.id)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            DispatchQueue.main.async { notificationScheduled = true }
        }
    }
    
    func scheduleNotificationAt(hour: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🎬 Dags att kolla!"
            content.body = "Du ville se \(movie.title) – starta filmen nu!"
            content.sound = .default
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "movie-\(movie.id)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            DispatchQueue.main.async { notificationScheduled = true }
        }
    }
    
    func scheduleNotificationTomorrow() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🎬 Dags att kolla!"
            content.body = "Du ville se \(movie.title) – starta filmen nu!"
            content.sound = .default
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            dateComponents.hour = 18
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "movie-\(movie.id)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            DispatchQueue.main.async { notificationScheduled = true }
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
