//
//  TodoItemCategoryWrapper.swift
//  ToDoList
//
//  Created by Andre Frank on 05.01.24.
//

import Foundation
import CoreData


enum Category : String, Identifiable, CaseIterable {
    case preventive = "PROACT"
    case reactive = "REACT"
    case project = "PROJECT"
    case other = "OTHER"
    case development = "DEVELOPMENT"
    
    var id:Self {
        self
    }
    
    var description:String? {
        switch self {
        case .preventive:
            return ""
        case .reactive:
            return nil
        case .project:
            return ""
        case .other:
            return nil
        case .development:
            return nil
        }
    }
    
}

class TodoCategory : NSManagedObject {
    @NSManaged var id:UUID
    
    @NSManaged public var categoryString:String
    @NSManaged public var detailString:String?
    
    func categoryDetail(_ category:Category) -> String? {
        return detail
    }
    
}

extension TodoCategory:Identifiable {
    var category:Category {
        Category(rawValue: categoryString)!
    }
    
    var detail:String? {
        switch category {
        case .preventive:
            return detailString ?? ""
        case .reactive:
            return nil
        case .project:
            return detailString ?? ""
        case .other:
            return nil
        case .development:
            return nil
        }
    }
}
