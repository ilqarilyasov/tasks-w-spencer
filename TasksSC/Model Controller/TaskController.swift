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
    
    func createTask(with name: String, notes: String?, priority: TaskPriority) {
        let task = Task(name: name, notes: notes, priority: priority)
        
        saveToPersistentStore()
        put(task: task)
    }
    
    func updateTask(task: Task, name: String, notes: String?, priority: TaskPriority) {
        task.name = name
        task.notes = notes
        task.priority = priority.rawValue
        
        saveToPersistentStore()
        put(task: task)
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
    
    
    // MARK: - Find task by identifier
    
    func task(for identifier: String) -> Task? {
        
        guard let id = UUID(uuidString: identifier) else {return nil}
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        
        do {
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching task with UUID: \(identifier) :\(error)")
            return nil
        }
    }
}

    // MARK: - Extension

extension TaskController {
    
    static let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - Fetch
    
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
                    
                    guard let priority = TaskPriority(rawValue: taskRep.priority) else {return}
                    
                    if let task = self.task(for: taskRep.identifier) {
                        self.updateTask(task: task, name: taskRep.name, notes: taskRep.notes, priority: priority)
                    } else {
                        let _ = Task(taskRepresentation: taskRep)
                    }
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
            self.saveToPersistentStore()
            
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
}
