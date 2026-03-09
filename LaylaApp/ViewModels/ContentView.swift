import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Hem", systemImage: "film")
                }
            
            SearchView()
                .tabItem {
                    Label("Sök", systemImage: "magnifyingglass")
                }
            
            WatchListView()
                .tabItem {
                    Label("Min Lista", systemImage: "bookmark.fill")
                }
        }
        .tint(.purple)
    }
}
