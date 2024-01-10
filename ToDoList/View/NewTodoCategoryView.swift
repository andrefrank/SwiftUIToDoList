//
//  NewCategorView.swift
//  ToDoList
//
//  Created by Andre Frank on 06.01.24.
//

import SwiftUI

struct NewTodoCategoryView: View {

    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var isShow: Bool

    @State var detail: String?
    @State var category: Category
    @State var isEditing = false
    @State var showDetail:Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("Neue Kategorie")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        isShow.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                
                Picker(selection: $category) {
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
                
                TextField("Detail eingeben", text: Binding(get: {
                    detail ?? ""
                }, set: { newValue in
                    detail = newValue
                    
                }), onEditingChanged: { (editingChanged) in
                    
                    self.isEditing = editingChanged
                    
                })
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom)
                .opacity(detail != nil ? 1 : 0)
                
            
            .onChange(of: category, { _, newValue in
                detail = newValue.description
            })
            .padding(.bottom, 10)
            
            // Save button for adding the category
            Button(action: {
                
                if let detail, detail.trimmingCharacters(in: .whitespaces) == "" {
                    return
                }
                
                addTodoCategory(category, detail: detail)
                
                isShow.toggle()
                
            }) {
                Text("Speichern")
                    .font(.system(.headline, design: .rounded))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10, antialiased: true)
        .offset(y: isEditing ? -320 : 0)
        
      }
       // .edgesIgnoringSafeArea(.bottom)
    }
       
   
    private func addTodoCategory(_ category:Category,detail: String?) {
        let todoCategory = TodoCategory(context: context)
            todoCategory.id = UUID()
        todoCategory.categoryString = category.rawValue
            todoCategory.detailString = detail
            
            context.saveChanges { error in
                if let error = error as? NSError {
                    print(error.localizedDescription)
                }
            }
    }
}



struct NewToDoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoCategoryView(isShow: .constant(true), detail: nil, category:.reactive)
            .environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
    }
}

