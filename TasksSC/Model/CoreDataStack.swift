//
//  CoreDataStack.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    // Will use this instead of saveToPersistence()
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        
        var error: Error? // For thows function will need an optional Error
        
        // This performs given code inside the context's queue
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TasksSC") // Needs to match up with data model file name
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistenet stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true // Parent - Child
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
