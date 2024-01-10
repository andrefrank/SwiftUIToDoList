//
//  ToDoItem.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 10/8/2022.
//

import Foundation
import CoreData

enum Priority: Int {
    case low = 0
    case normal = 1
    case high = 2
}

class ToDoItem: NSManagedObject {
    @NSManaged var id:UUID
    
    @NSManaged var name: String
    @NSManaged var priorityNum: Int32
    @NSManaged var isComplete: Bool
    @NSManaged var startDate:Date?
    @NSManaged var completionDate:Date?
    @NSManaged var nextDate:Date?
    @NSManaged var scheduledDate:Date?
    @NSManaged var note:String?
    @NSManaged var estimateTimeToComplete:Double
    @NSManaged var isActive:Bool
    
    @NSManaged var category:TodoCategory?
}

extension ToDoItem : Identifiable {
    var priority:Priority {
        set {
            self.priorityNum = Int32(newValue.rawValue)
        } get{
            return Priority(rawValue: Int(priorityNum)) ?? .normal
        }
    }
}
