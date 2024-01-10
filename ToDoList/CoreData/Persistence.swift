//
//  PersistentController.swift
//  ToDoList
//
//  Created by Andre Frank on 30.12.23.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    private init(inMemory:Bool=false){
    
        container = NSPersistentContainer(name: "ToDoList")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        
        container.loadPersistentStores { description, error in
            if let error = error as? NSError {
                fatalError("Fehler beim Laden der Datenbank \(error.userInfo)")
            }
            print(description)
        }
    }
    
    let container:NSPersistentContainer
    
    
    func saveChanges(){
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("Failed to save to Core Data",error.localizedDescription,error.localizedDescription,error.userInfo)
                
            }
        }
    }
    
    static var previewTodoCategory:TodoCategory = {
        let context = preview.container.viewContext
        let item = TodoCategory(context:context)
        item.id = UUID()
        item.categoryString = Category.preventive.rawValue
        item.detailString = "vEFK - Prüforganisation"
        
        return item
    }()
    
    static var previewTodo:ToDoItem = {
        let context = preview.container.viewContext
        let item = ToDoItem(context:context)
        
        item.id = UUID()
        item.name = "K13 Programmanpassung"
        item.note = "St12 Entnahme von iO Teile"
        item.priority = .high
        item.completionDate = nil
        item.startDate = Date()
        item.isComplete = false
        item.scheduledDate = nil
        item.estimateTimeToComplete = 1200
        
        do {
            try context.save()
        }catch {
            print(error)
        }
        
        return item
    }()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let todoCategory = TodoCategory(context: viewContext)
        todoCategory.categoryString = "Project"
        todoCategory.detailString = "New Slitter"
        todoCategory.id = UUID()

        for index in 0..<10 {
            let newItem = ToDoItem(context: viewContext)
            newItem.id = UUID()
            
            newItem.name = "Aufgabe #\(index)"
            newItem.priority = .normal
            newItem.isComplete = false
            newItem.startDate = Date()
            newItem.estimateTimeToComplete = 3.5
            newItem.note = ""
            newItem.scheduledDate = nil
            newItem.completionDate = nil
            newItem.category = todoCategory
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unerwarteter Fehler \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

}
