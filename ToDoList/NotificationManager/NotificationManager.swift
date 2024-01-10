//
//  NotificationManager.swift
//  ToDoList
//
//  Created by Andre Frank on 02.01.24.
//

import SwiftUI
import UserNotifications
import Combine



class NotificationManager:NSObject,ObservableObject,UNUserNotificationCenterDelegate {
    ///Notify UI when Local Notfications settings are  are changed
    @Published var isEnabled:Bool=false
    
    static let shared = NotificationManager()
    
    ///Allow badges,sound and alert
    private let notificationOption:UNAuthorizationOptions = [.alert,.badge,.sound]
    
    ///Observing reference
    private var subscriptions = Set<AnyCancellable>()
   
    ///The wrapped task to request authorization for local Notifications
    private lazy var requestAuthorizationTask:Task<Void,Never> = {
        let task = Task {
            let retValue = await self.requestAuthorization()
            await MainActor.run {
                isEnabled = retValue
            }
        }
        
        return task
    }()
    
    
    private override init(){
        super.init()
        ///Request authorization when servce is loaded
        /// normally this will ask only once
        UNUserNotificationCenter.current().setBadgeCount(0)
        Task {
            await requestAuthorizationTask.result
        }
        
        registerCategories()
        
        ///Setup Settings notfication by  observing the applications foreground active state and handle authorization status
        subscribeToSettingsNotification()
    }
    
    
    private func subscribeToSettingsNotification(){
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    let isGranted:Bool
                    //get Notfication status
                    if case .authorized = settings.authorizationStatus {
                        isGranted = true
                    } else {
                        isGranted = false
                        
                    }
                    
                    //Enable or disable accordingly on the main thread for the UI
                    DispatchQueue.main.async {
                        self.isEnabled = isGranted
                    }
                }
            
            }
            .store(in: &subscriptions)
    }
    
    private func requestAuthorization()async ->Bool {
        ///Convert from completion handler to async await method to handle notfication authorization
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: notificationOption) { isGranted, error in
                guard error == nil && isGranted else {
                    continuation.resume(returning: false)
                    return
                }
                
                continuation.resume(returning: true)
            }
        }
    }
    
    
    func openAppSettingsForNotificationAuthorization(){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler:nil)
    }
    
    
    func installNotificationMessage(_ message:String, title:String,subTitle:String,messageIdentifier:String,atDate dueDate:Date, threadIdentifier:String="TodoList", categoryIdentifier:String="Reminder",hour:Int,minute:Int){
        
        //Set content of the notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.interruptionLevel = .active
        content.subtitle = subTitle
        
        //Group the notification
        content.threadIdentifier=threadIdentifier
        
        //Use custom actions
        content.categoryIdentifier = categoryIdentifier
        content.userInfo=["customData":"fizzbuzz"]
        
        
        content.sound = UNNotificationSound.default
        
       
    
        //Create reminder date with specified time of day
        let calendar = Calendar(identifier: .gregorian)
       
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)

        //Specify custom daytime for triggering the notification
        components.hour = hour
        components.minute = minute

        let reminderDate = calendar.date(from: components)
        components = calendar.dateComponents([.year,.month, .day, .hour, .minute], from: reminderDate!)
        
        
        // Set Trigger event
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // 4
        let request = UNNotificationRequest(identifier: messageIdentifier, content: content, trigger: trigger)
        // 5
        
        //Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
           
        }
    }
    
    
    func removeNotificationMessage(_ messageIdentifier:String){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [messageIdentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [messageIdentifier])
    }
    

    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "Details zur Aufgabe", options: .foreground)
        let category = UNNotificationCategory(identifier: "Reminder", actions: [show], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
            let userInfo = response.notification.request.content.userInfo

            if let customData = userInfo["customData"] as? String {
                print("Custom data received: \(customData)")

                switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    // the user swiped to unlock
                    print("Default identifier")

                case "show":
                    // the user tapped our "show more info…" button
                    print("Show more information")
                    break

                default:
                    break
                }
            }

            // you must call the completion handler when you're done
            completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let presentationOptions:UNNotificationPresentationOptions = [.banner,.list,.sound]
        completionHandler(presentationOptions)
    }
  
}
