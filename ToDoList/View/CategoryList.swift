//
//  CategoryList.swift
//  ToDoList
//
//  Created by Andre Frank on 06.01.24.
//

import SwiftUI


struct CategoryList:View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appdata:AppData
    
    @FetchRequest(entity: TodoCategory.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TodoCategory.categoryString, ascending: true)]) var categories:FetchedResults<TodoCategory>
    
    //The observed managed object
    @ObservedObject var todo:ToDoItem
    
    @State var searchText:String=""
    @State var showNewCategory:Bool=false
    @State var filterPredicate:NSPredicate?=nil
    @State var filterType:Int=0
    
    
    var body: some View {
            ZStack {
                VStack {
                    headerView
                        .padding()
                    List {
                        ForEach(categories) { categoryItem in
                            CategoryListRow(categoryItem: categoryItem, selectedCategory: Binding(get: {
                                todo.category
                            }, set: { newValue in
                                todo.category = newValue
                            }))
                        }
                        .onDelete(perform: { indexSet in
                           deleteCategory(indexSet)
                        })
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { _ ,newValue in
                        //  let predicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS %@", newValue)
                    }
                    
                }
                .rotation3DEffect(Angle(degrees: showNewCategory ? 5 : 0), axis: (x: 1, y: 0, z: 0))
                .offset(y: showNewCategory ? -50 : 0)
                .animation(.easeOut, value: showNewCategory)
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                }
                    // If there is no data, show the welcome view
                if categories.count == 0 && filterPredicate == nil {
                    WelcomeView(message: "Mit + neue Kategorie anlegen")
                }
                    
                    // Display the "Add new todo" view
                if showNewCategory {
                    BlankView(bgColor: .black)
                        .opacity(0.5)
                        .onTapGesture {
                            self.showNewCategory = false
                        }
                }
                 
                if showNewCategory {
                    NewTodoCategoryView(isShow: $showNewCategory, detail:nil, category:.reactive)
                        .transition(.move(edge: .bottom))
                        .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0), value: showNewCategory)
                }
            
        }
    }
    
    
    private func deleteCategory(_ indexSet:IndexSet){
        for index in indexSet {
                let itemToDelete = categories[index]
            
                context.delete(itemToDelete)
        }
        
        context.saveChanges(){ error in
            if let error = error as? NSError {
                print(error.localizedDescription)
            }
        }
    }
}


extension CategoryList {
    var headerView:some View {
        HStack {
            Text("Kategorien")
                .font(.system(size: 40, weight: .black, design: .rounded))
            
            Spacer()
            
            Button(action: {
                //Add Category
                showNewCategory.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
            }
        }
    }
}


struct CategoryListPreview : PreviewProvider {
    static var context = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        CategoryList(todo: PersistenceController.previewTodo)
            .environment(\.managedObjectContext,context)
            .environmentObject(AppData())
    }
}
