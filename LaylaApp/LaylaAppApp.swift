import SwiftUI
import SwiftData

@main
struct LaylaAppApps: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SavedMovie.self, WatchList.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
