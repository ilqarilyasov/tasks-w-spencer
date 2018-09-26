//
//  TaskRepresentation.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Equatable {
    
    var name: String
    var notes: String?
    var timestamp: Date
    var priority: String
    var identifier: UUID
}
