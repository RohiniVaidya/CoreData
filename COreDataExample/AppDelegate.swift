//
//  AppDelegate.swift
//  COreDataExample
//
//  Created by Admin on 5/5/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    lazy var coreDataStack: CoreDataStack = { return CoreDataStack() }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //        application.registerForRemoteNotifications()
        //
        //
        //        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .sound, .badge]], completionHandler: { (granted, error) in
        //            if granted{
        //            }
        //        })
        //        UNUserNotificationCenter.current().delegate = self
        //self.addRemoteNotificationSubscription()
        
        if let options: NSDictionary = launchOptions as NSDictionary? {
            let remoteNotification =
                options[UIApplication.LaunchOptionsKey.remoteNotification]
            if let notification = remoteNotification {
                
                self.application(application, didReceiveRemoteNotification:
                    notification as! [AnyHashable : Any],
                                 fetchCompletionHandler:  { (result) in
                                    print("received remote notification \(result)")
                })
                
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notification: CKNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String:Any])!
        
        if notification.notificationType == CKNotification.NotificationType.query{
            
            let queryNotification = notification as! CKQueryNotification
            
            let recordID = queryNotification.recordID
            
            let container = CKContainer(identifier: "iCloud.com.rohini.COreDataExample")
            
            let database = container.privateCloudDatabase
            database.fetch(withRecordID: recordID!) { (record, error) in
                guard let record = record else { return }
                
                let managedObjContext = self.coreDataStack.persistentContainer.viewContext
                let fetchReq = NSFetchRequest<Person>(entityName: "Person")
                let predicate = NSPredicate(format: "name = %@", argumentArray: [record.value(forKey: "CD_name") as! String]) // Specify your condition here
                fetchReq.predicate = predicate
                do{
                    let data = try managedObjContext.fetch(fetchReq)
                    print("DEBUG: value for the name is \(data)")
                }
                catch{
                    
                }
            }
            
            
        }
    }
    
    
    //MARK: -  Subscribing to remote notification
    func addRemoteNotificationSubscription(){
        let container = CKContainer(identifier: "iCloud.com.rohini.COreDataExample")
        
        let database = container.privateCloudDatabase
        
        database.fetchAllSubscriptions { (subscriptions, error)  in
            guard error == nil else {
                print("ERROR: error in subscribing to remote notifications \(String(describing: error?.localizedDescription))")
                
                return
                
            }
            guard let subscriptions = subscriptions else { return }
            for subscription in subscriptions {
                
                database.delete(withSubscriptionID: subscription.subscriptionID) { (success, error) in
                    if error != nil{
                        print("ERROR: error in subscribing to remote notifications \(String(describing: error?.localizedDescription))")
                    }
                }
                
            }
            
            let predicate = NSPredicate(value: true)
            //Add the record type
            let subscription = CKQuerySubscription(recordType: "CD_Person", predicate: predicate, options: .firesOnRecordCreation)
            let notification = CKSubscription.NotificationInfo()
            notification.alertBody = "Remote notification"
            notification.soundName = "default"
            
            subscription.notificationInfo = notification
            database.save(subscription) { (subscription, error) in
                guard error == nil else {
                    print("ERROR: error in saving the subdcription \(String(describing: error?.localizedDescription))")
                    return
                }
                
                print("DEBUG: successully subscribed to remote notification \(subscription.debugDescription)")
            }
            
            
        }
        
        
    }
    
}

