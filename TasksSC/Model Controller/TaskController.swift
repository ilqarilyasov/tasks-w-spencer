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
}

    // MARK: Extension

extension TaskController {
    
    static let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
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
                
                for taskRep in tasRepresentations {
                    let _ = Task(taskRepresentation: taskRep)
                }
                
                self.saveToPersistentStore()
                completion(nil)
            } catch {
                NSLog("Error decoding task representations: \(error)")
                completion(error)
                return
            }
            
        }.resume()
    }
}
