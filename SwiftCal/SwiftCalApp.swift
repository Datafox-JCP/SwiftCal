//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 21/07/24.
//

import SwiftUI

@main
struct SwiftCalApp: App {
    @State private var selectedTab = 0
    
    let persistenceController = PersistenceController.shared

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
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
