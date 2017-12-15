//
//  AppDelegate.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import FacebookCore
import Fabric
import Crashlytics
import SocketIO
import SwiftyJSON
import IQKeyboardManagerSwift
import Firebase
import HockeySDK
import UserNotifications

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

public struct ezdebug {
    public static let email = "ios@test.com"
    public static let password = "iOStest12345"
    public static let is4test = "mohamed@attitudetech.ie"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let gcmMessageIDKey = "gcm.message_id"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
#if !DEBUG
        BITHockeyManager.shared().configure(withIdentifier: PTConstants.keys.hockeyAppAppId)
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation() // This line is obsolete in the crash only builds
        
        Fabric.with([Crashlytics.self])
#endif
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        // Register for remote push notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    
        
        // Configure UI
        configureUIPreferences()

        // KeyboardManager
        IQKeyboardManager.sharedManager().enable = true

        
        var out = true
        
        if DataManager.instance.isAuthenticated() {
            if let socialMedia = DataManager.instance.isSocialMedia() {
                if let sm = SocialMedia(rawValue: socialMedia) {
                    switch sm {
                    case .facebook:
                        out = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                    default:
                        break
                    }
                }
            }
            loadHomeScreen()
        } else {
            loadAuthenticationScreen()
        }
        
        return out
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func loadHomeScreen() {
//        if runningTripArray.isEmpty == false {
            let root = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            root.selectedIndex = 0
            window?.rootViewController = root
}
    
    func loadAuthenticationScreen() {
            let initial = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController
            window?.rootViewController = initial
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.instance.disconnect()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.instance.connect()
    }
    
    var visibleViewController: UIViewController? {
        
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            if  let navigationController = tabBarController.selectedViewController as? UINavigationController {
                return navigationController.viewControllers.last!
            }else{
                return tabBarController.selectedViewController
            }
        }
        return nil
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.instance.disconnect()
        CoreDataManager.instance.save { (_) in }
    }
    
    private func configureUIPreferences() {
        UIApplication.shared.statusBarStyle = .default
        UINavigationBar.appearance().backgroundColor = UIColor.secondary
        UINavigationBar.appearance().barTintColor = UIColor.secondary
        UINavigationBar.appearance().tintColor = UIColor.primary
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title2),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        UITabBar.appearance().tintColor = UIColor.primary
        UITableViewCell.appearance().tintColor = UIColor.primary
        UISwitch.appearance().onTintColor = UIColor.primary
        UISegmentedControl.appearance().tintColor = UIColor.primary
        UIActivityIndicatorView.appearance().color = UIColor.primary
//        UILabel.appearance().backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    //    MARK:- GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Reporter.send(file: "\(#file)", function: "\(#function)", error)
        }else{
            if let root = window?.rootViewController as? InitialViewController {
                root.successGoogleLogin(token: user.authentication.idToken)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Reporter.send(file: "\(#file)", function: "\(#function)", error)
        }
    }
    
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        
        if let data = userInfo["aps"] as! [String:Any]! {
            if let alert = data["alert"] as! [String:Any]! {
                print("\(String(describing: alert))")
                if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                    rootViewController.alert(title: alert["title"] as! String, msg: alert["body"] as! String, type: notificationType.blue, disableTime: 5, handler: nil)
                }
            }
        }

        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
  
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
 
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
