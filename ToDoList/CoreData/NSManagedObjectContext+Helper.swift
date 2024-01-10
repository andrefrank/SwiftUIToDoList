//
//  NSManagedObject+Helper.swift
//  ToDoList
//
//  Created by Andre Frank on 08.01.24.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func saveChanges(doRollback:Bool=false, _ completion:((Error?)->Void)?=nil) {
        var retError:NSError?=nil
        
        if self.hasChanges {
            do {
                if doRollback{
                    self.rollback()
                } else {
                    try self.save()
                }
                
            } catch {
                retError = error as NSError
               
            }
        }
        completion?(retError)
    }
}
