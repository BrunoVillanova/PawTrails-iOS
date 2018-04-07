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
import IQKeyboardManagerSwift
import Firebase
import HockeySDK
import UserNotifications
import CocoaLumberjackSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var storyboard: UIStoryboard?
    let gcmMessageIDKey = "gcm.message_id"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
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
    
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Configure UI
        configureUIPreferences()

        // KeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
        //reset Onboarding presented
        OnboardingViewController.onboardingPresented = false

        if let socialMedia = DataManager.instance.isSocialMedia(), let sm = SocialMedia(rawValue: socialMedia), sm == .facebook {
            return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        return true
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
            Reporter.debugPrint("Message ID: \(messageID)")
        }
        
        // Print full message.
//        Reporter.debugPrint(userInfo)
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
            Reporter.debugPrint("Message ID: \(messageID)")
        }
        
        // Print full message.
        Reporter.debugPrint("\(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Reporter.debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Reporter.debugPrint("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    
    open func loadHomeScreen(animated: Bool) {
        let root = storyboard!.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        self.window?.rootViewController = root
    }
    
    func loadTutorial() {
        
        let root = storyboard!.instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
        let navigationController = UINavigationController.init(rootViewController: root)

        if let currentRootViewController = self.window?.rootViewController {
            UIView.transition(from:currentRootViewController.view, to: navigationController.view, duration: 0.5, options: UIViewAnimationOptions.transitionCurlDown, completion: {(finished) in
                self.window?.rootViewController = navigationController
            })
        } else {
            window?.rootViewController = navigationController
        }
    }
    
    func showOnboardingIfNeeded(_ animated: Bool = true) {
        if !OnboardingViewController.onboardingPresented && !OnboardingViewController.onboardingCompleted {
            self.showOnboardingModally(animated)
        }
    }
    
    func showOnboardingModally(_ animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "onboarding")
        window?.rootViewController?.present(vc, animated: animated, completion: nil)
    }
    
    func showPetWizardModally(_ animated: Bool = true) {
        let storyboard = UIStoryboard(name: "PetWizard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "wizard")
        window?.rootViewController?.present(vc, animated: animated, completion: nil)
    }
    
    func changeRootViewController(_ viewController: UIViewController, animated: Bool = false) {
        if let currentRootViewController = self.window?.rootViewController {
            UIView.transition(from:currentRootViewController.view, to: viewController.view, duration: 0.3, options: UIViewAnimationOptions.transitionCurlDown, completion: {(finished) in
                self.window?.rootViewController = viewController
            })
        } else {
            window?.rootViewController = viewController
        }
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
    }
}

enum Storyboards {
    case login
    
    var storyboard: UIStoryboard {
        switch self {
            case .login: return UIStoryboard(name: "Login", bundle: nil)
        }
    }
}

enum ViewControllers {
    case initial, login, signup, passwordRecovery, emailVerification
    
    var storyboard: UIStoryboard {
        switch self {
            case .initial, .login, .signup, .passwordRecovery, .emailVerification: return Storyboards.login.storyboard
        }
    }
    
    var identifier: String {
        switch self {
            case .initial: return "InitialViewController"
            case .login: return "LoginViewController"
            case .signup: return "SignUpViewController"
            case .passwordRecovery: return "PasswordRecoveryViewController"
        case .emailVerification: return "EmailVerificationViewController"
        }
    }
    
    var navigationController: UINavigationController? {
        switch self {
        case .login, .signup, .passwordRecovery: return UINavigationController()
        default: return nil
        }
    }
    
    var viewController: UIViewController {
        return self.storyboard.instantiateViewController(withIdentifier: self.identifier)
    }
}

//
// MARK: Screens functions
//
extension AppDelegate {
    
    func loadAuthenticationScreen(_ presentEmailValidation: Bool = false) {
        
  
        if let vc = ViewControllers.initial.viewController as? InitialViewController {
            
            let navController = UINavigationController(rootViewController: vc)
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                
                
                UIView.transition(from: rootViewController.view, to: navController.view, duration: 0.3, options: .transitionCrossDissolve) { finished in
                    if finished {
                        self.window?.rootViewController = navController
                        self.presentViewController(.login, animated: false, completion: {
                            self.presentViewController(.emailVerification, animated: true, completion: nil)
                        })
                    }
                }
            }
        }
    }
    
    func presentViewController(_ viewControllerType: ViewControllers, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        var viewControllerToPresent = viewControllerType.viewController
        
        if let navigationController = viewControllerType.navigationController {
            navigationController.viewControllers = [viewControllerToPresent]
            viewControllerToPresent = navigationController
        }

        presentViewController(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.present(viewController, animated: animated, completion: completion)
            } else {
                rootViewController.present(viewController, animated: animated, completion: completion)
            }
        }
    }
    
    func getVisibleViewController() -> UIViewController? {
        var visibleViewController: UIViewController?
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            
            if let presentedViewController = rootViewController.presentedViewController {
                visibleViewController = presentedViewController
            } else {
                visibleViewController = rootViewController
            }
        }
  
        return visibleViewController
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
            Reporter.debugPrint("Message ID: \(messageID)")
        }

        
        if let data = userInfo["aps"] as! [String:Any]? {
            if let alert = data["alert"] as! [String:Any]? {
                Reporter.debugPrint("\(String(describing: alert))")
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
            Reporter.debugPrint("Message ID: \(messageID)")
        }
  
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Reporter.debugPrint("Firebase registration token: \(fcmToken)")
        
 
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Reporter.debugPrint("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
