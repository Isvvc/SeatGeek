//
//  Persistence.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    static let test = PersistenceController(inMemory: true)
    
    /// Convenience property the returns the shared instance's container's view context.
    static var mainContext: NSManagedObjectContext {
        shared.container.viewContext
    }
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SeatGeek")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    //MARK: Saving
    
    /// Saves the container's viewContext if there are changes.
    func save() {
        PersistenceController.save(context: container.viewContext)
    }
    
    /// Saves the given context if there are changes.
    /// - Parameter context: The Core Data context to save.
    static func save(context moc: NSManagedObjectContext) {
        guard moc.hasChanges else { return }
        do {
            try moc.save()
            print("Saved")
        } catch {
            let nsError = error as NSError
            NSLog("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
    
}
