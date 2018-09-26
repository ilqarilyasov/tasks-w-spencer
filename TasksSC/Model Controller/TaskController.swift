//
//  TaskController.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class TaskController {
    
    // MARK: - CRUD
    
    func createTask(with name: String, notes: String?, priority: TaskPriority) {
        _ = Task(name: name, notes: notes, priority: priority)
        
        saveToPersistentStore()
    }
    
    func updateTask(task: Task, name: String, notes: String?, priority: TaskPriority) {
        task.name = name
        task.notes = notes
        task.priority = priority.rawValue
        
        saveToPersistentStore()
    }
    
    func deleteTask(task: Task) {
        CoreDataStack.shared.mainContext.delete(task)
        
        saveToPersistentStore()
    }
    
    // MARK: - Persistent
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving moc: \(error)")
        }
    }
    
    var tasks: [Task] {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let descriptor = NSSortDescriptor(key: "name", ascending: false)
        //fetchRequest.predicate = NSPredicate(format: "notes CONTAINS %@", "a")
        //fetchRequest.predicate = NSPredicate(format: "timestamp < %@", Date() as NSDate)
        fetchRequest.sortDescriptors = [descriptor]
        
        let moc = CoreDataStack.shared.mainContext
        
        do {
           return try moc.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching task: \(error)")
            return []
        }
    }
}
