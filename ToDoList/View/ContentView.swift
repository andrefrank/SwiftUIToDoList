//
//  ContentView.swift
//  ToDoList
//
//  Created by Andre Frank on 04.01.24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var appData:AppData
    
    var body: some View {
        TabView {
            ToDoList()
                .tabItem {
                    Label("Aufgaben", systemImage: "list.bullet.circle")
                }
            
            ReportsView()
                .tabItem {
                    Label("Report", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppData())
}

struct NestedItemA: View {
    var body: some View {
        NavigationStack {
            Text("Report A Platzhalter")
                .navigationTitle("Report A")
        }
    }
}

struct NestedItemB: View {
    var body: some View {
        NavigationStack {
            Text("Report B Platzhalter")
                .navigationTitle("Report B")
        }
    }
}
