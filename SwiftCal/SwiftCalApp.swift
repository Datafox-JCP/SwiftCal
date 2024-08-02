//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 21/07/24.
//

import SwiftUI
import SwiftData

@main
struct SwiftCalApp: App {
    @State private var selectedTab = 0
    
    static var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mx.datafox.SwiftCal")!
        return container.appendingPathComponent("SwiftCal.sqlite")
    }
    
    let container: ModelContainer = {
        let config = ModelConfiguration(url: sharedStoreURL)
        return try! ModelContainer(for: Day.self, configurations: config)
    }()
    

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                CalendarView()
                    .tabItem { Label("Calendario", systemImage: "calendar") }
                    .tag(0)
                
                StreakView()
                    .tabItem { Label("Racha", systemImage: "swift") }
                    .tag(1)
            }
            .modelContainer(container)
            .onOpenURL { url in
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
            }
        }
    }
    
    init() {
        #if DEBUG
            print("➡️ Base de datos: " + URL.applicationSupportDirectory.path(percentEncoded: false))
        #endif
    }
}
