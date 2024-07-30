//
//  Persistence.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 21/07/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let databaseName = "SwiftCal.sqlite"
    
    var oldStoreUrl: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName)
    }
    
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mx.datafox.SwiftCal")!
        return container.appendingPathComponent(databaseName)
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)!.start
        
        for dayOffset in 0..<30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
            newDay.didStudy = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SwiftCal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if !FileManager.default.fileExists(atPath: oldStoreUrl.path) {
            print("👀 oldStore existe, se migrará a sharedStoreURL")
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        
        print("🕸️ container URL = \(container.persistentStoreDescriptions.first!.url!)")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func migrateStore(for container: NSPersistentContainer) {
        let coordinator = container.persistentStoreCoordinator
        
        guard let oldStore = coordinator.persistentStore(for: oldStoreUrl) else { return }
        print("👀 Ubicación de la base de datos")
        
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("✅ Se completó la migración de la base de datos")
        } catch {
            fatalError("😈 No fue posible migrar la base de datos")
        }
        
        do {
            try FileManager.default.removeItem(at: oldStoreUrl)
            print("🗑️ Base de datos oldStore eliminada")
        } catch {
            print("🗑️ No fue posible eliminar la base de datos")
        }
    }
}
