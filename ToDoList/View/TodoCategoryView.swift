//
//  TodoItemCategoryView.swift
//  ToDoList
//
//  Created by Andre Frank on 06.01.24.
//

import SwiftUI

struct TodoCategoryView : View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var todoItem:ToDoItem
    
    @State var selection:Category = .reactive
    @State var detail:String=""
    
    var body: some View {
        HStack {
            HStack(alignment:.center) {
                Picker(selection: $selection) {
                    ForEach(Category.allCases,id:\.self){ item in
                        Text(item.rawValue).tag(item.rawValue)
                    }
                } label: {
                    EmptyView()
                }
                .labelsHidden()
                .foregroundStyle(.white)
                .tint(colorScheme == .light ? .black : .white)
                .background(colorScheme == .light ? Color(.systemGray6) : .black)
                .cornerRadius(5)
                .disabled(true)
                .onAppear {
                    if let todoCategory = todoItem.category {
                        selection = todoCategory.category
                        detail = todoCategory.detailString ?? ""
                    } else {
                        selection = .reactive
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Detail")
                        .foregroundStyle(colorScheme == .light ? .black : .black)
                    TextField("Detail", text: $detail)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding()
                        .background(colorScheme == .light ? Color(.systemGray6) : .black)
                        .cornerRadius(5)
                        .disabled(true)
                }
                .opacity(todoItem.category?.detailString != nil ? 1 : 0)
            }
            .onChange(of: selection) { oldValue, newValue in
                print(newValue)
            }
        }
    }
}

#Preview {
    TodoCategoryView(todoItem:ToDoItem(context: PersistenceController.preview.container.viewContext))
}
