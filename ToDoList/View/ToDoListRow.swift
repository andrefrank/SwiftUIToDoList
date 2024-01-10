//
//  ToDoListRow.swift
//  ToDoList
//
//  Created by Andre Frank on 30.12.23.
//

import SwiftUI

struct ToDoListRow: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appData:AppData
    
    @ObservedObject var todoItem: ToDoItem

    
    var body: some View {
        Toggle(isOn: self.$todoItem.isComplete) {
            VStack(alignment:.leading) {
                HStack {
                    todoNameView
                    Spacer()
                #if DEBUG
                    nextDateAndScheduleFlagView
                    Spacer()
                #endif
                    priorityLabelView
                }
                
                HStack {
                    startDateView
                    Spacer()
                    activeProgressView
                    completionTimeLabelView
                    Spacer()
                    alarmLabelView
                }
            }
        }
        .toggleStyle(CheckboxStyle())
        .onChange(of: todoItem.isComplete) { _ , newValue  in
            completeToDoItem(newValue)
        }
        .onDisappear{
            appData.persistenceController.saveChanges()
        }
    }
}

extension ToDoListRow {
    var todoNameView : some View {
        Text(self.todoItem.name)
            .strikethrough(self.todoItem.isComplete, color: .purple)
            .bold()
            .animation(.default)
    }
    
    var priorityLabelView: some View {
        HStack {
            Text(label(for: self.todoItem.priority))
                .font(.system(size: 12,design: .rounded))
                .bold()
            
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(self.color(for: self.todoItem.priority))
        }
    }
    
    var alarmLabelView : some View {
        Group {
            Text(formattedDate(todoItem.scheduledDate ?? Date()))
                .font(.system(size: 12,design: .rounded))
            Image(systemName: "alarm.waves.left.and.right")
                .foregroundStyle((todoItem.scheduledDate ?? Date()) >= Date() ? .black : Color(.systemRed))
        }
        .opacity(todoItem.scheduledDate != nil ? 1 : 0)
    }
    
    var startDateView: some View {
        Text(formattedDate(todoItem.startDate))
            .font(.system(size: 12,design: .rounded))
        
    }
    
    @ViewBuilder var activeProgressView : some View {
        if todoItem.isActive {
            ProgressView()
                .tint(.purple)
                .padding(.horizontal,5)
        } else {
            ProgressView()
                .hidden()
                .padding(.horizontal,5)
        }
    }
    
    var completionTimeLabelView: some View {
        Text(formattedEstimateCompletionTime(todoItem.estimateTimeToComplete))
            .font(.system(size: 12,design: .rounded))
    }
    
    @ViewBuilder var nextDateAndScheduleFlagView: some View {
        if let nextDate = todoItem.nextDate, let recentTodoItem = appData.recentTodoItem {
            VStack(alignment:.leading,spacing: 2) {
                Text("Aktiv")
                    .font(.system(size: 8))
                Text(formattedTime(nextDate))
                    .font(.system(size: 8))
            }
            .padding(.horizontal,8)
            .padding(.vertical,8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.2))
                
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red)
            }
        } else {
            EmptyView()

        }
    }
}


extension ToDoListRow {
    private func completeToDoItem(_ isEnabled:Bool) {
        todoItem.completionDate = isEnabled ? Date() : nil
        
        //Task is completed, so stop time calculation
        if isEnabled {
            todoItem.isActive = false
            todoItem.scheduledDate = nil
            appData.recentTodoItem = nil
           // updateTime(todoItem: todoItem, isEnabled: false)
        }
    }
    
    private func color(for priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .normal: return .orange
        case .low: return .green
        }
    }
    
    private func label(for priority:Priority) -> String {
        switch priority {
        case .high: return "HOCH"
        case .normal: return "NORMAL"
        case .low: return "NIEDRIG"
        }
    }
    
    private func formattedDate(_ date:Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.dateFormat = "DD-MM-yyyy"
        
        return df.string(from: date)
    }
    
    private func formattedTime(_ date:Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateFormat = "HH:mm"
        
        return df.string(from: date)
    }
   
    
    private func formattedEstimateCompletionTime(_ time:Double) -> String {
        var formattedTime=""
        
        let days = Int(time / (24*3600))
        var value = time.truncatingRemainder(dividingBy: 24 * 3600)
        
        if days>=1{
            formattedTime = "\(days) \(days>2 ? "Tage" : "Tag")"
        }
        
        let hours = Int(value / 3600)
        value = time.truncatingRemainder(dividingBy: 3600)
        
        if hours>=1{
            formattedTime += "\(hours) Std."
        }
        
        
        let minutes = Int(value / 60)
        value = time.truncatingRemainder(dividingBy: 60)
        
        if minutes>=1{
            formattedTime += "\(minutes) Min."
        }
        
        return formattedTime
    }
}


#Preview {
    ToDoListRow(todoItem:PersistenceController.previewTodo)
        .environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
        .environmentObject(AppData())
}

