//
//  ToDoItemDetail.swift
//  ToDoList
//
//  Created by Andre Frank on 31.12.23.
//

import SwiftUI

struct ToDoItemDetail : View {
    @Environment(\.managedObjectContext) var context
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
   
    //The observed managed object
    @ObservedObject var todo:ToDoItem
    
    //Edit state
    @State private var isEditing:Bool=false
    @FocusState private var isNoteFocused:Bool
    
    //Triggers alert
    @State private var alertMessage:String?
    
    //Additonal actions when after aletrmessage
    @State private var isNotificationAllowed:Bool=false
    @State private var noCategoryPresent:Bool=false
    
    //Reminder related properties and state settings
    let notificationManager = NotificationManager.shared
    
    @State private var scheduledDate:Date=Date()
    @State private var scheduledTime:Date=Date()
    @State private var isScheduled:Bool=false
    
    //Language settings
    @State private var isLocalizedDefault:Bool=true
    
   

    var body: some View {
        VStack {
            header
            .padding()
            
            VStack(alignment: .leading) {
                sectionHeader(title: "Aufgabe")
                inputTodoView
                
                .padding(.bottom,10)
                
                sectionHeader(title: "Kategorie")
                
                NavigationLink {
                    CategoryList(todo: todo)
                } label: {
                    TodoCategoryView(todoItem: todo)
                    .padding(.bottom,10)
                }

                sectionHeader(title: "Priorität")
                priorityView
                .padding(.bottom, 10)
                
                sectionHeader(title: "Erinnerung")
                reminderView
                .padding(.bottom, 10)
                
                
                sectionHeader(title: "Notiz")
                noteView
                .padding(.bottom, 10)
                
                // Save button for adding the todo item
                saveButton
                .padding(.bottom, 40)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10, antialiased: true)
            
            Spacer()
        }
        .onTapGesture {
            if todo.isComplete {
                alertMessage = "Aufgabe ist bereits erledigt.\n Es können keine Änderungen vorgenommen werden."
            }
        }
        .onAppear{
            if todo.category == nil {
                ///Set flag to indicate additional exception handling
                noCategoryPresent=true
                
                alertMessage = "Es wurde noch keine Kategorie angelegt für die Aufgabe"
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden)
        .showAlert(alertMessage: $alertMessage, title: "Meldung", onAction: {
            
            ///Additional error handling
            if !isNotificationAllowed {
                notificationManager.openAppSettingsForNotificationAuthorization()
            }
            
        })
    }
}

//MARK: - Methods
extension ToDoItemDetail {
    
    func notificationForTodo(_ todo:ToDoItem,scheduleddDay:Date, atTime:Date){
        ///do not register notification if disabled or Todo is completed
        guard notificationManager.isEnabled, !todo.isComplete else {return}
        
        /// Extract Hours and minute from selected time
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour,.minute], from: atTime)
        
        /// Save scheduled date
        todo.scheduledDate = scheduleddDay
            
        /// Remove outstanding notifications before add a new one if schedule day is valid otherwise remove any outstanding notifications
        if let scheduledDate = todo.scheduledDate, isScheduled {
            notificationManager.removeNotificationMessage(todo.id.uuidString)
            
            notificationManager.installNotificationMessage("Erinnerung", title: todo.name, subTitle: todo.note ?? "keine Notiz", messageIdentifier: todo.id.uuidString, atDate: scheduledDate, hour: components.hour!, minute: components.minute!)
        } else {
            notificationManager.removeNotificationMessage(todo.id.uuidString)
            todo.scheduledDate = nil
        }
    }
    
    func updateScheduledDate(){
        if isScheduled {
            todo.scheduledDate = scheduledDate
        } else {
            todo.scheduledDate = nil
            scheduledDate = Date()
        }
    }
}


//MARK: - Additional Child Views
extension ToDoItemDetail {
    func sectionHeader(title:String)-> some View {
        Text(title)
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.black)
            .bold()
    }
    
    
    var inputTodoView:some View {
        TextField("Aufgabenbeschreibung eingeben", text: $todo.name, onEditingChanged: { (editingChanged) in
            
             self.isEditing = editingChanged
            
        })
        .focused($isNoteFocused)
        .padding()
        .background(Color(.systemGray6))
        .font(.system(size: 22,design: .rounded))
        .cornerRadius(8)
        .disabled(todo.isComplete)
    }
    
    
    var noteView:some View {
        TextEditor(text: Binding(get: {
            todo.note ?? ""
        }, set: { newValue in
            todo.note = newValue
        }))
        .focused($isNoteFocused)
        .scrollDismissesKeyboard(.interactively)
        .scrollContentBackground(.hidden)
        .frame(height:120)
        .background(Color(.systemGray6))
        .foregroundStyle(colorScheme == .light ? .black : .white)
        .font(.system(size: 22,design: .rounded))
        .cornerRadius(15)
        .disabled(todo.isComplete)
       
    }
    
    var reminderView:some View {
        HStack {
            Toggle("", isOn: $isScheduled)
            .labelsHidden()
            .tint(.purple)
            .onAppear{
                isScheduled = todo.scheduledDate != nil
                scheduledDate = todo.scheduledDate ?? Date()
            }
            .disabled(!isNotificationAllowed || todo.isComplete)
            
            
            Text(isScheduled ? "An" : "Aus")
                .foregroundStyle(.black)
                .frame(maxWidth:.infinity,alignment: .leading)
    
            Spacer()
            
            DatePicker("", selection:$scheduledDate, displayedComponents: [.date])
                .environment(\.locale, Locale.init(identifier:isLocalizedDefault ? "de" : "en"))
                .foregroundStyle(.white)
                .background(colorScheme == .light ? Color(.systemGray6) : .black)
                .cornerRadius(8,antialiased: true)
                .disabled(!isScheduled || !isNotificationAllowed || todo.isComplete)
            
            Spacer()
            
            DatePicker("", selection:$scheduledTime, displayedComponents: [.hourAndMinute])
                .environment(\.locale, Locale.init(identifier:isLocalizedDefault ? "de" : "en"))
                .foregroundStyle(.white)
                .background(colorScheme == .light ? Color(.systemGray6) : .black)
                .cornerRadius(8,antialiased: true)
                .disabled(!isScheduled || !isNotificationAllowed || todo.isComplete)
            
                
        }
        .onTapGesture {
            if !notificationManager.isEnabled && !todo.isComplete {
               alertMessage = "Mitteilungen sind momentan für die App nicht erlaubt.\nWenn sie diese aktivieren wollen, müssen die Einstellungen ändern"
            }
        }
        .onChange(of: isScheduled ) { oldValue, newValue in
            updateScheduledDate()
        }
        .onReceive(notificationManager.$isEnabled, perform: { publishedValue in
            isNotificationAllowed = publishedValue
        })
    }
    
    var priorityView:some View {
        HStack {
            Text("Hoch")
                .font(.system(.headline, design: .rounded))
                .padding(10)
                .background(todo.priority == .high ? Color.red : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    todo.priority = .high
                }
                .disabled(todo.isComplete)
            
            Text("Normal")
                .font(.system(.headline, design: .rounded))
                .padding(10)
                .background(todo.priority == .normal ? Color.orange : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    todo.priority = .normal
                }
                .disabled(todo.isComplete)
            
            Text("Niedrig")
                .font(.system(.headline, design: .rounded))
                .padding(10)
                .background(todo.priority == .low ? Color.green : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    todo.priority = .low
                }
                .disabled(todo.isComplete)
        }
    }
    
    var header:some View {
        HStack {
            Text("Details")
                .font(.system(size: 40, weight: .black, design: .rounded))
                
            Spacer()
            
            headerCancelButton
        }
    }
    
    var headerCancelButton:some View {
        HStack {
            Text("")
                .font(.system(.title, design: .rounded))
                .bold()
            
            Spacer()
            
            Button(action: {
                
                context.saveChanges(doRollback: true){ error in
                    dismiss()
                }
                
            }) {
                Image(systemName: "xmark")
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .font(.headline)
            }
        }
    }
    
    var saveButton:some View {
        Button(action: {
            guard todo.name.trimmingCharacters(in: .whitespaces) != "" else {
                alertMessage = "Aufgabe muß einen Namen haben!"
                return
            }
            
            #if !DEBUG
                if scheduledDate <= Date().advanced(by: 23*3600) && isScheduled {
                    alertMessage = "Erinnerung für Aufgabe ist nur an Folgetagen möglich!"
                    return
                }
            #endif
            
            notificationForTodo(todo, scheduleddDay:scheduledDate,atTime:scheduledTime)
            
            context.saveChanges { error in
                if let error = error as? NSError {
                    print(error.localizedDescription)
                }
                dismiss()
            }
            
        }) {
            Text("Save")
                .font(.system(.headline, design: .rounded))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(todo.isComplete ? Color(.systemGray4) : Color.purple)
                .cornerRadius(10)
        }
        .disabled(todo.isComplete)
        .padding(.bottom)
        
    }
}


extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

#Preview {
    ToDoItemDetail(todo:PersistenceController.previewTodo)
        .environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
}
