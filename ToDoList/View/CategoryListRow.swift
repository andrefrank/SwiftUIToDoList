//
//  CategoryListView.swift
//  ToDoList
//
//  Created by Andre Frank on 09.01.24.
//

import SwiftUI

struct CategoryListRow: View {
    @Environment(\.dismiss) var dismiss
    
    let categoryItem:TodoCategory
    @Binding var selectedCategory:TodoCategory?
    
    var body: some View {
        HStack {
            Text(categoryItem.categoryString)
                .font(.system(size: 20,design: .rounded))
            Spacer()
            
            Text(categoryItem.detail ?? "")
                .font(.system(size: 12,design: .rounded))
                .opacity(categoryItem.detail != nil ? 1 : 0)
        }
        .padding(.horizontal)
        .contextMenu {
            Button {
                
                selectedCategory = categoryItem
                dismiss()
            } label: {
                Label("Übernehmen", systemImage:  "checkmark.circle")
                
            }
        }
    }
}

#Preview {
    CategoryListRow(categoryItem: PersistenceController.previewTodoCategory, selectedCategory: Binding(get: {
        nil
    }, set: { newValue in
        
    }))
}
