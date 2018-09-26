//
//  Task+Convenience.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String {
    
    case low
    case normal
    case high
    case critical
    
    static var allPriorities: [TaskPriority] {
        return [.low, .normal, .high, .critical]
    }
}

extension Task {
    
    convenience init(name: String,
                     notes: String?,
                     timestamp: Date = Date(),
                     priority: TaskPriority = .normal,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.name = name
        self.notes = notes
        self.timestamp = timestamp
        self.priority = priority.rawValue
        self.identifier = identifier
    }
    
    var taskRespresentation: TaskRepresentation? {
        
        guard let name = name,
            let timestamp = timestamp,
            let priority = priority,
            let identifier = identifier else {return nil}
        
        return TaskRepresentation(name: name, notes: notes, timestamp: timestamp, priority: priority, identifier: identifier.uuidString)
    }
}
