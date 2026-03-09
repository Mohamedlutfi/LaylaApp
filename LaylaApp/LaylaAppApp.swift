//
//  LaylaAppApp.swift
//  LaylaApp
//
//  Created by Mohamed Lutfi Mohamed on 2026-03-09.
//

import SwiftUI
import SwiftData

@main
struct LaylaApp: App {
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
