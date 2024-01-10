//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Simon Ng on 10/8/2022.
//

import SwiftUI
import CoreData

class AppData : ObservableObject {
    let persistenceController = PersistenceController.shared
    
    var recentTodoItem: FetchedResults<ToDoItem>.Element?
}

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var appData = AppData()

    
    var body: some Scene {
        WindowGroup {
            //TestView()
            ContentView()
            .environment(\.managedObjectContext,appData.persistenceController.container.viewContext)
            .environmentObject(appData)
            .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
                            case .background:
                                print("State change to background....",appData.recentTodoItem)
                            case .inactive:
                                print("State changed to Inactive....")
                            case .active:
                                print("State changed to Active....")
                                appDelegate.appData = appData
                        default:
                            break
                        }
                    }
        }
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var appData:AppData!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here when using AppDelegate in SwiftUI App")
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Terminate")
        if let todoItem = appData.recentTodoItem {
            todoItem.isActive = false
            todoItem.nextDate = nil
            
        }
        appData.persistenceController.saveChanges()
    }
}
