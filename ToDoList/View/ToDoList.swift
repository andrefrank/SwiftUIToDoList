//
//  ContentView.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 10/8/2022.
//

import SwiftUI

struct ToDoList: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appData:AppData
    
    @FetchRequest(entity: ToDoItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ToDoItem.priorityNum, ascending: true)]) var todoItems:FetchedResults<ToDoItem>
    
    
    @State private var newItemName: String = ""
    @State private var newItemPriority: Priority = .normal
    @State private var showNewTask = false
    @State private var selectedTodoItem:ToDoItem?=nil
    
    @State private var searchText:String=""
    @State private var filterType=0
    
    @State private var filterPredicate:NSPredicate?=nil
    
    
    static let kcWorkTimeInterval:TimeInterval=30
    private let workTimer = Timer.publish(every: Self.kcWorkTimeInterval, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    headerView
                    filterView
                    .padding(.bottom,30)

                    List {
                        ForEach(todoItems) { todoItem in
                            ToDoListRow(todoItem: todoItem)
                                .hiddenDisclosure {
                                    ToDoItemDetail(todo: todoItem)
                                }
                                .contextMenu {
                                    Button {
                                        if let selectedTodoItem, selectedTodoItem == todoItem {
                                            self.selectedTodoItem=nil
                                        } else {
                                            selectedTodoItem = todoItem
                                        }
                                    } label: {
                                        Label(todoItem.isActive ? "Stop" : "Starte Aufgabe", systemImage: todoItem.isActive ? "stop.circle" : "restart.circle")
                                        
                                    }
                                    .disabled(todoItem.isComplete)
                                }
                                .onReceive(workTimer, perform: { _ in
                                    if todoItem.isActive {
                                        updateTime(todoItem: todoItem, isEnabled: true)
                                    }
                                })
                            #if DEBUG
                                .listRowBackground(selectedTodoItem == todoItem ? Color.blue.opacity(0.2) : Color.clear)
                            #endif
                        }
                       
                        .onDelete(perform: { indexSet in
                            deleteTask(indexSet: indexSet)
                        })
                                           
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
                    .onChange(of: selectedTodoItem, { oldItem, newItem in
                        if let oldItem {
                            updateTime(todoItem: oldItem, isEnabled:false)
                        }
                        if let newItem {
                            updateTime(todoItem: newItem, isEnabled: true)
                        }
                        
                        setRecent(todoItem: newItem)
                        
                    })
                    
                    .onChange(of: searchText) { _ ,newValue in
                                
                        let predicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS %@", newValue)
                        
                       filterTodoItems(with: predicate)
                        
                    }
                    .onChange(of:filterType) {
                        oldValue,
                        newValue in
                        guard filterType != 0 else {
                            filterTodoItems(
                                with: nil)
                            return
                        }
                        
                        filterTodoItems(
                            with: NSPredicate(
                                format: "isComplete = %d",
                                false
                            )
                        )
                    }
                }
                .rotation3DEffect(Angle(degrees: showNewTask ? 5 : 0), axis: (x: 1, y: 0, z: 0))
                .offset(y: showNewTask ? -20 : 0)
                .animation(.easeOut, value: showNewTask)
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                }
                
                
                // If there is no data, show the welcome view
                if todoItems.count == 0 && filterPredicate == nil {
                    WelcomeView(message: "Mit + neue Aufgabe anlegen...")
                }
                
                // Display the "Add new todo" view
                if showNewTask {
                    BlankView(bgColor: .black)
                        .opacity(0.5)
                        .onTapGesture {
                            self.showNewTask = false
                        }
                    
                    NewToDoView(isShow: $showNewTask, name: "", priority: .normal)
                        .transition(.move(edge: .bottom))
                        .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0), value: showNewTask)
                }
            }
        }
    }
    
    func filterTodoItems(with predicate:NSPredicate?){
        self.filterPredicate = predicate
        todoItems.nsPredicate = predicate
    }
    
    func deleteTask(indexSet:IndexSet){
        for index in indexSet {
                let itemToDelete = todoItems[index]
                context.delete(itemToDelete)
        }
        
        self.runOnMainThread {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}


extension ToDoList {
    private func setRecent(todoItem:ToDoItem?){
        appData.recentTodoItem = todoItem
        if let todoItem {
            todoItem.isActive=true
        }
    }
    
    private func updateTime(todoItem:ToDoItem,isEnabled:Bool){
        if isEnabled {
            guard let nextDate = todoItem.nextDate else {
                todoItem.nextDate = Date()
                return
            }
            
            let differenceTime = Date().timeIntervalSince(nextDate)
            todoItem.nextDate = Date()
            
            todoItem.estimateTimeToComplete += differenceTime
        } else {
            todoItem.isActive = false
            todoItem.nextDate = nil
        }
        
        print(todoItem.estimateTimeToComplete)
    }
    
}


extension ToDoList {
    var headerView: some View {
        HStack {
            Text("Aufgabenliste")
                .font(.system(size: 40, weight: .black, design: .rounded))
            
            Spacer()
            
            Button(action: {
                self.showNewTask = true
                
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
            }
        }
        .padding()
    }
    
    var filterView: some View {
        Picker("Hallo", selection: $filterType) {
            Text("Alle").tag(0)
            Text("Offen").tag(1)
        }
        .pickerStyle(.segmented)
        .frame(width:240)
        .background(colorScheme == .dark ? .purple : .white)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoList()
            .environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
            .environmentObject(AppData())
    }
}
