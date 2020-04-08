//
//  AppDelegate.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import OneSignal
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //        func userDidLogin(userId: String) {
        //            self.startOneSignal()
        //        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (note) in
            let userId = note.userInfo![kUSERID] as! String
            UserDefaults.standard.set(userId, forKey: kUSERID)
            UserDefaults.standard.synchronize()
            //userDidLogin(userId: userId)
        }
        
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        var pushToken: String?
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                pushToken = result.token
                print(pushToken!)
                if pushToken != nil {
                    if let playerId = pushToken {
                        UserDefaults.standard.set(playerId, forKey: kPUSHID)
                        updateCurrentUserInFirestore(withValues: [kPUSHID : pushToken]) { (error) in
                            if error != nil {
                                print("error updating push id \(error!.localizedDescription)")
                            }
                        }
                    } else {
                        UserDefaults.standard.removeObject(forKey: kPUSHID)
                    }
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        
        
        //        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        //
        //        OneSignal.initWithLaunchOptions(launchOptions,
        //        appId: kONESIGNALAPPID,
        //        handleNotificationAction: nil,
        //        settings: onesignalInitSettings)
        //
        //        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        //
        //        // Recommend moving the below line to prompt for push after informing the user about
        //        //   how your app will use them.
        //        OneSignal.promptForPushNotifications(userResponse: { accepted in
        //        print("User accepted notifications: \(accepted)")
        //        })
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
            }
        }
        
        locationManagerStart()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                
            }
        }
        locationManagerStop()
    }
    
    func locationManagerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
        
    }
    
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      let userInfo = notification.request.content.userInfo

      // Print chatroom ID.
      if let messageID = userInfo["chatroom_id"] {
        print("Message ID: \(messageID)")
      }

    
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo["chatroom_id"])")
    }
    
    
    
    
    
    func locationManagerStop() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinates = locations.last!.coordinate
    }
    
    //    func startOneSignal() {
    //        let status : OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
    //        let userID = status.subscriptionStatus.userId
    //        let pushToken = status.subscriptionStatus.pushToken
    //
    //        if pushToken != nil {
    //            if let playerId = userID {
    //                UserDefaults.standard.set(playerId, forKey: kPUSHID)
    //            } else {
    //                UserDefaults.standard.removeObject(forKey: kPUSHID)
    //            }
    //            UserDefaults.standard.synchronize()
    //        }
    //
    //        updateOneSignalId()
    //    }
    
}



