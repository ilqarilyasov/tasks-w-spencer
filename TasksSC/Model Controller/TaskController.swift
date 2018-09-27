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
    
    init() {
        fetchTasksFromServer()
    }
    
    // MARK: - CRUD
    
    func createTask(with name: String, notes: String?, priority: TaskPriority, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let task = Task(name: name, notes: notes, priority: priority, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving task: \(error)")
        }
        
        put(task: task)
    }
    
    func updateTask(task: Task, name: String, notes: String?, priority: TaskPriority) {
        task.name = name
        task.notes = notes
        task.priority = priority.rawValue
        
        put(task: task)
//
//        guard let context = task.managedObjectContext else {return}
//        do {
//            try CoreDataStack.shared.save(context: context)
//        } catch {
//            NSLog("Error updating task: \(error)")
//        }
    }
    
    func deleteTask(task: Task) {
        let moc = CoreDataStack.shared.mainContext
        deleteTaskFromServer(task: task)
        moc.delete(task)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            moc.reset() // Clear out the context, so there is nothing in it
            NSLog("Error saving moc after deleting task: \(error)")
        }
    }
    
    // MARK: - Find task by identifier
    
    func task(for identifier: String, in context: NSManagedObjectContext) -> Task? {
        
        guard let id = UUID(uuidString: identifier) else {return nil}
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        
        var result: Task? = nil
        
        context.performAndWait {
            do {
                result =  try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with UUID: \(identifier) :\(error)")
            }
        }
        return result
    }
}

extension TaskController {
    
    static let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - Fetch from Server - Needs a BACKGROUND CONTEXT
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = TaskController.baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data return from data task")
                completion(error)
                return
            }
            
            do {
                let tasRepresentations = try JSONDecoder().decode([String: TaskRepresentation].self, from: data).map({ $0.value })
                
                // MARK: Creata a background context
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                backgroundContext.performAndWait {
                    for taskRep in tasRepresentations {
                        
                        guard let priority = TaskPriority(rawValue: taskRep.priority) else {return}
                        
                        if let task = self.task(for: taskRep.identifier, in: backgroundContext) {
                            self.updateTask(task: task, name: taskRep.name, notes: taskRep.notes, priority: priority)
                        } else {
                            let _ = Task(taskRepresentation: taskRep, context: backgroundContext)
                        }
                    }
                    
                    // Save background context
                    do {
                        try CoreDataStack.shared.save(context: backgroundContext)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                    
                }
                completion(nil)
            } catch {
                NSLog("Error decoding task representations: \(error)")
                completion(error)
                return
            }
            
        }.resume()
    }
    
    // MARK: - Put
    
    func put(task: Task, compeltion: @escaping CompletionHandler = { _ in }) {
        
        let identifier = task.identifier ?? UUID()
        let requestURL = TaskController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var taskRepresentation = task.taskRespresentation else {
                compeltion(NSError())
                return
            }
            
            taskRepresentation.identifier = identifier.uuidString
            task.identifier = identifier
            
            try CoreDataStack.shared.save()
            
            request.httpBody = try JSONEncoder().encode(taskRepresentation)
        } catch {
            NSLog("Error encoding task representation: \(error)")
            compeltion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting task: \(error)")
                compeltion(error)
                return
            }
            compeltion(nil)
        }.resume()
    }
    
    // MARK: - Delete
    
    func deleteTaskFromServer(task: Task, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = task.identifier else {
            NSLog("No identifier for task to delete")
            completion(NSError())
            return
        }
        
        let requestURL = TaskController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
        }.resume()
    }
}
