//
//  View+RunOnMainThread.swift
//  ToDoList
//
//  Created by Andre Frank on 31.12.23.
//

import SwiftUI


extension View {
    func runOnMainThread(_ task:@escaping () -> Void){
        Task {
            await MainActor.run {
                task()
            }
        }
    }
}
