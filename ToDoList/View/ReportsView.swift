//
//  ReportsView.swift
//  ToDoList
//
//  Created by Andre Frank on 05.01.24.
//

import SwiftUI

struct ReportsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Reports")
                Divider()
                NavigationLink(destination: NestedItemB()) {
                    Text("Hier soll ein Report erstellt werden können")
                }
                .navigationTitle("Reports")
            }
        }
    }
}
